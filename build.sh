#!/bin/bash

go get github.com/grafana/grafana
cd $GOPATH/src/github.com/grafana/grafana
go run build.go setup
go run build.go build

yarn install --pure-lockfile
yarn dev

sed /http_port/s/3000/8080/ -i conf/defaults.ini
