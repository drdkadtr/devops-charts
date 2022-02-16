#!/bin/bash

SCHEMA_LOCATION="https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/"

if ! [ -x "$(command -v kubeval)" ]; then
  curl -sSL -o /tmp/kubeval.tar.gz https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz
  tar -C /usr/local/bin -xf /tmp/kubeval.tar.gz kubeval
fi

set -e
set -u
set -x

for dir in charts/*; do
    echo "Helm dependency build..."
    helm dependency build --skip-refresh "$dir"

    echo "Kubeval(idating) ${dir##charts/} chart..."
    helm template "${dir}" | kubeval --strict --ignore-missing-schemas --schema-location "${SCHEMA_LOCATION}"
done
