#!/bin/bash

set -eou pipefail
set -x

git clone -b "$BRANCH" --depth=1 --single-branch https://"${PERSONAL_TOKEN}"@github.com/"${GITHUB_REPO}".git "${GITHUB_REPO}"
mkdir -p "${GITHUB_REPO}"/files/
cp -af files/* "${GITHUB_REPO}"/files/

cd "${GITHUB_REPO}" || exit 1
helm repo index .

git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git add files index.yaml
git status -s . | cat -
git remote -v
git commit -m "Github Actions: ${GITHUB_SHA}"
git push -v https://"${PERSONAL_TOKEN}"@github.com/"${GITHUB_REPO}".git
