#!/bin/bash

set -e
set -u
set -x

for dir in charts/*; do
    echo -e "\n *** Verifying and packing $dir ***\n"
    helm dependency update --skip-refresh "$dir"
    helm lint "$dir"
    helm package "$dir" --destination "files/"
done

helm repo index .
