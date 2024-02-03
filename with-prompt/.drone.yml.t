---
to: <%= appname %>/.drone.yml
force: true
---
workspace:
  base: /go
  path: src/github.com/udistrital/${DRONE_REPO##udistrital/}
  when:
      branch:
      - develop
      - release/*
      - master

kind: pipeline
name: oas_api_ci

steps:
- name: check_readme
  failure: ignore
  image: jjvargass/qa_develoment:latest
  commands:
  - python /app/check_readme.py
  when:
    branch:
    - develop
    - feature/*
    - release/*
    - hotfix/*
    event:
    - push

- name: check_branch
  image: jjvargass/qa_develoment:latest
  commands:
  - python /app/check_branch.py -H ${DRONE_GIT_HTTP_URL}
  when:
    branch:
    - develop
    - feature/*
    - hotfix/*
    - release/*
    event:
    - push

- name: check_commits
  image: jjvargass/qa_develoment:latest
  commands:
  - python /app/check_commits.py
  when:
    branch:
    - develop
    - feature/*
    - hotfix/*
    - release/*
    event:
    - push

- name: go_build
  image: golang:<%= goversion %>
  commands:
  - go get -t
  - GOOS=linux GOARCH=amd64 go build -o main
  when:
    branch:
    - feature/*
    - hotfix/*
    - develop
    - release/*
    - master
    event:
    - push

- name: go_run_test
  image: golang:<%= goversion %>
  commands:
  - go get -t
  - go get github.com/smartystreets/goconvey/convey
  - curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.41.1
  - go get github.com/axw/gocov/...
  - go get github.com/AlekSi/gocov-xml
  - go get -u github.com/jstemmer/go-junit-report
  - golangci-lint run | tee report.xml
  when:
    branch:
    - feature/*
    - hotfix/*
    - develop
    - release/*
    - master
    event:
    - push

- name: run_sonar_scanner
  image: aosapps/drone-sonar-plugin
  settings:
    sonar_host:
      from_secret: SONAR_HOST
    sonar_token:
      from_secret: SONAR_TOKEN

- name: beego_migrate
  image: golang:<%= goversion %>
  failure: ignore
  environment:
    PG_MIGRATION_USER:
      from_secret: PG_MIGRATION_USER
    PG_MIGRATION_PASS:
      from_secret: PG_MIGRATION_PASS
    PG_MIGRATION_URL:
      from_secret: PG_MIGRATION_URL
    PG_MIGRATION_DBNAME:
      from_secret: PG_MIGRATION_DBNAME
  commands:
  - go get -t
  - go get -u github.com/beego/bee
  - bee migrate -driver=postgres -conn="postgres://$${PG_MIGRATION_USER}:$${PG_MIGRATION_PASS}@$${PG_MIGRATION_URL}:5432/$${PG_MIGRATION_DBNAME}?sslmode=disable"
  when:
    branch:
    - release/*
    event:
    - push

- name: beego_rollback
  image: golang:<%= goversion %>
  failure: ignore
  environment:
    PG_MIGRATION_USER:
      from_secret: PG_MIGRATION_USER
    PG_MIGRATION_PASS:
      from_secret: PG_MIGRATION_PASS
    PG_MIGRATION_URL:
      from_secret: PG_MIGRATION_URL
    PG_MIGRATION_DBNAME:
      from_secret: PG_MIGRATION_DBNAME
  commands:
  - go get -t
  - go get -u github.com/beego/bee
  - bee migrate rollback -driver=postgres -conn="postgres://$${PG_MIGRATION_USER}:$${PG_MIGRATION_PASS}@$${PG_MIGRATION_URL}:5432/$${PG_MIGRATION_DBNAME}?sslmode=disable"
  when:
    branch:
    - release/*
    status:
    - failure

- name: publish_to_ecr_release
  image: plugins/ecr
  settings:
    access_key:
      from_secret: AWS_ACCESS_KEY_ID
    secret_key:
      from_secret: AWS_SECRET_ACCESS_KEY
    region:
      from_secret: AWS_REGION
    repo: ${DRONE_REPO##udistrital/}
    tags:
      - ${DRONE_COMMIT:0:7}
      - release
  when:
    branch:
    - release/*
    event:
    - push

- name: publish_to_ecr_master
  image: plugins/ecr
  settings:
    access_key:
      from_secret: AWS_ACCESS_KEY_ID
    secret_key:
      from_secret: AWS_SECRET_ACCESS_KEY
    region:
      from_secret: AWS_REGION
    repo: ${DRONE_REPO##udistrital/}
    tags:
      - ${DRONE_COMMIT:0:7}
      - latest
  when:
    branch:
    - master
    event:
    - push

- name: update_aws_ecs
  image: golang:<%= goversion %>
  environment:
    AWS_ACCESS_KEY_ID:
      from_secret: AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY:
      from_secret: AWS_SECRET_ACCESS_KEY
    AWS_CONTAINER:
      from_secret: AWS_CONTAINER
  commands:
  - case ${DRONE_BRANCH} in
       release/*)
         AMBIENTE=test
         CLUSTER=test
         MYCONTAINER=$${AWS_CONTAINER}/${DRONE_REPO##udistrital/}:release
         ;;
       master)
         AMBIENTE=prod
         CLUSTER=oas
         MYCONTAINER=$${AWS_CONTAINER}/${DRONE_REPO##udistrital/}:latest
         ;;
    esac
  - AWS_REGION=us-east-1
  - SERVICE=${DRONE_REPO##udistrital/}_$AMBIENTE
  - container_name=${DRONE_REPO##udistrital/}
  - apt-get update
  - apt-get install unzip
  - wget https://github.com/Autodesk/go-awsecs/releases/download/v1.1/update-aws-ecs-service-linux-amd64.zip
  - unzip update-aws-ecs-service-linux-amd64.zip -d /go/bin
  - AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY} AWS_REGION=$AWS_REGION
    $GOPATH/bin/update-aws-ecs-service -cluster $CLUSTER -service $SERVICE -container-image $MYCONTAINER
  when:
    branch:
    - release/*
    - master
    event:
    - push

- name: notify_telegram
  image: appleboy/drone-telegram
  settings:
    token:
      from_secret: telegram_token
    to:
      from_secret: telegram_to
    format: html
    message: >
      {{#success build.status}}
        ✅ <a href="{{build.link}}">SUCCESS</a> <b>Build #{{build.number}}</b>
        <b>type: </b><code>{{ build.event }}</code>
        <b>Repo: </b><code>{{repo.name}}</code>
        <b>Branch: </b><code>{{commit.branch}}</code>
        <b>Commit: </b><a href="{{commit.link}}">{{truncate commit.sha 7}}</a>
        <b>Autor: </b>{{commit.author}} <code>&#128526 </code>
      {{else}}
        ❌ <a href="{{build.link}}">FAILURE</a> <b>Build #{{build.number}}</b>
        <b>type: </b><code>{{ build.event }}</code>
        <b>Repo: </b><code>{{repo.name}}</code>
        <b>Branch: </b><code>{{commit.branch}}</code>
        <b>Commit: </b><a href="{{commit.link}}">{{truncate commit.sha 7}}</a>
        <b>Autor: </b>{{commit.author}} <code>&#128549 </code>
      {{/success}}
  when:
    branch:
    - release/*
    - master
    event:
    - push
    status:
    - failure
    - success
