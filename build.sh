#!/bin/bash

go get github.com/grafana/grafana
cd $GOPATH/src/github.com/grafana/grafana
if [[ -z "${GRAFANA_VERSION}" ]]; then
  echo "No GRAFANA_VERSION environment variable set"
  exit 1
fi

git checkout "${GRAFANA_VERSION}"
go get -v all
go run build.go build

mkdir -p $GOPATH/bin/

for bin in grafana-cli grafana-server; do
  cp $GOPATH/src/github.com/grafana/grafana/bin/linux-amd64/${bin} $GOPATH/bin/
done

yarn install --pure-lockfile
yarn build

mkdir -p data/plugins
cd data/plugins

git clone https://github.com/ovh/ovh-warp10-datasource.git

