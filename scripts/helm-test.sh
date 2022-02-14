#!/bin/bash
  
# About: install a local chart before releasing

set -e

# If BASEDIR is undefined, set it using git.
if [ -z "$BASEDIR" ] && git --version >/dev/null 2>&1; then
    BASEDIR=$(git rev-parse --show-toplevel)
    source "$BASEDIR"/scripts/constants.sh
fi

# Constants
NAMESPACE="ci"

install(){

  helm "${HELM_ARGS[@]}" "${CHART_NAME}" ./charts/"${CHART_NAME}" \
      --create-namespace \
      --namespace="$NAMESPACE" \
      --set replicaCount=2
  
  kubectl wait --for=condition=Ready pods --all --all-namespaces --timeout=300s
  
  # TODO: write more tests here ...
}

main() {
  if [ "$1" == "--remove" ]; then
    context_workspace_check
    clusterrolebinding_create
    helm_v3_check
    uninstall
    clusterrolebinding_delete
  else
    context_workspace_check
    clusterrolebinding_create
    helm_v3_check
    install
    clusterrolebinding_delete
  fi
}

main "$@"
