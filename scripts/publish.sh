#!/bin/bash

BRANCH=${BRANCH:-main}

set -eou pipefail
set -x

git clone -b "$BRANCH" --depth=1 --single-branch https://"${PERSONAL_TOKEN}"@github.com/"${GITHUB_REPO}".git "${GITHUB_REPO}"
cp -af files/* "${GITHUB_REPO}"/files/

cd "${GITHUB_REPO}"
helm repo index .

git add files index.yaml
git status -s . | cat -
git remote -v
git commit -m "Github Actions: $(date +"%Y-%m-%d %H:%M")"
git push -v https://"${PERSONAL_TOKEN}"@github.com/"${GITHUB_REPO}".git
