#!/bin/bash
set -eou pipefail
set -x

git clone --depth=1 --single-branch https://"${GITHUB_TOKEN}":x-oauth-basic@github.com/"${GITHUB_REPO}".git

git add files index.yaml
git commit -m "Update"

git push https://"${GITHUB_TOKEN}":x-oauth-basic@github.com/"${GITHUB_REPO}".git
