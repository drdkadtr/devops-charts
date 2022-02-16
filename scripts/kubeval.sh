#!/bin/bash

set -e
set -u
set -x

KUBEVAL_VERSION="0.16.1"
SCHEMA_LOCATION="https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/"

if ! [ -x "$(command -v kubeval)" ]; then
  curl curl -sSL -o /tmp/kubeval.tar.gz https://github.com/instrumenta/kubeval/releases/download/"${KUBEVAL_VERSION}"/kubeval-linux-amd64.tar.gz
  sudo tar -C /usr/local/bin -xf /tmp/kubeval.tar.gz kubeval
fi

for dir in charts/*; do
    echo "Helm dependency build..."
    helm dependency build --skip-refresh "$dir"

    echo "Kubeval(idating) ${dir##charts/} chart..."
    helm template "${dir}" | kubeval --strict --ignore-missing-schemas --schema-location "${SCHEMA_LOCATION}"
done
