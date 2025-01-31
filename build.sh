#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${GRAFANA_VERSION:-}" ]]; then
  echo "No GRAFANA_VERSION environment variable set"
  exit 1
fi

if [[ -z "${GRAFANA_SHA_256:-}" ]]; then
  echo "No GRAFANA_SHA_256 environment variable set"
  exit 1
fi

wget https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz
echo "${GRAFANA_SHA_256}  grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz" | sha256sum -c
tar -zxf grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz
rm grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz

if [[ $GRAFANA_VERSION == 11* ]]; then
    mv grafana-v${GRAFANA_VERSION} grafana
else
    mv grafana-${GRAFANA_VERSION} grafana
fi

cd grafana

if [[ -n "${GRAFANA_PLUGINS:-}" ]]; then

  mkdir -p data/plugins

  ## Load custom plugins (set in GRAFANA_PLUGINS env variable)

  cd data/plugins
  plugins="${GRAFANA_PLUGINS}"
  readarray -td, array <<<"$plugins,"
  unset 'array[-1]'
  declare -p array
  for plugin in "${array[@]}"
  do
    if [[ $plugin == http* ]]
    then
      git clone "$plugin"
    else 
      name=${plugin%%:*}
      version=${plugin##*:}
      if [ "$name" != "$version" ];
      then
        ../../bin/grafana cli plugins install "$name" "$version"
      else 
        ../../bin/grafana cli plugins install "$name"
      fi
    fi
  done

fi