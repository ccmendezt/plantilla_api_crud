---
sh: git clone https://github.com/udistrital/refactor_controller.git && cd refactor_controller && git checkout version/0.0.2 && python2.7 main.py -F $GOPATH/src/github.com/udistrital/<%= appname %>/controllers && cd $GOPATH/src/github.com/udistrital/<%= appname %>/controllers && gofmt -w *.go && goimports -w *.go && cd $GOPATH/src/github.com/udistrital/<%= appname %> && rm go.mod && go mod init && go mod tidy && bee generate docs && bee generate migration crear_bd_<%= appname %>
---
