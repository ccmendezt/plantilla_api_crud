---
to: <%= appname %>/Dockerfile
force: true
---
FROM python:3
RUN pip3 install awscli
WORKDIR /
COPY entrypoint.sh entrypoint.sh
COPY main main
COPY conf/app.conf conf/app.conf
RUN chmod +x main entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]