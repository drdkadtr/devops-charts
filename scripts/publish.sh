#!/bin/bash
set -eou pipefail
set -x

git config -l | cat -
git clone --depth=1 --single-branch https://"${GITHUB_TOKEN}":x-oauth-basic@github.com/"${GITHUB_REPO}".git

git add files index.yaml
git status -s . | cat -

git commit -m "Github Actions: $(date +"%Y-%m-%d %H:%M")"
git push https://"${GITHUB_TOKEN}":x-oauth-basic@github.com/"${GITHUB_REPO}".git
