#!/bin/bash

set -euo pipefail

if [[ -z "${GRAFANA_VERSION}" ]]; then
  echo "No GRAFANA_VERSION environment variable set"
  exit 1
fi

git clone https://github.com/grafana/grafana --depth=1 --branch "${GRAFANA_VERSION}"

cd grafana

make all

mkdir -p $GOPATH/bin/

for bin in grafana-cli grafana-server; do
  cp bin/linux-amd64/${bin} $GOPATH/bin/
done

mkdir -p data/plugins
cd data/plugins

git clone https://github.com/ovh/ovh-warp10-datasource.git

