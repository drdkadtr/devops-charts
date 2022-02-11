#!/bin/bash
set -eou pipefail
set -x

git config -l | cat -
git clone --depth=1 --single-branch https://"${PERSONAL_TOKEN}"@github.com/"${GITHUB_REPO}".git
cp -af files index.yaml "${GITHUB_REPO}"/

cd "${GITHUB_REPO}"
git add files index.yaml
git status -s . | cat -
git remote -v
git commit -m "Github Actions: $(date +"%Y-%m-%d %H:%M")"
git push -v https://"${PERSONAL_TOKEN}"@github.com/"${GITHUB_REPO}".git
