#!/bin/bash

go get github.com/grafana/grafana
cd $GOPATH/src/github.com/grafana/grafana
go run build.go setup
go run build.go build

yarn install --pure-lockfile
yarn dev

mkdir -p data/plugins
cd data/plugins

git clone https://github.com/ovh/ovh-warp10-datasource.git
