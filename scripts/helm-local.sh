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
UPDATED_CHARTS=$(ct list-changed --config ct.yaml)

install(){

  for CHART in "${UPDATED_CHARTS[@]}";
  do
      IFS='/' read -ra CHART_ARRAY <<< "$CHART"
      CHART_NAME=${CHART_ARRAY[1]}
      HELM_VALUES=()
        
      CHART_VALUES_FILE="$CHART_NAME.test.yaml"
      if [[ -f "$CHART_VALUES_FILE" ]]; then HELM_VALUES+=(-f "$CHART_VALUES_FILE"); fi

      helm "${HELM_ARGS[@]}" "${CHART_NAME}" "${CHART}" \
        --create-namespace \
        --namespace="$NAMESPACE" "${HELM_VALUES[@]}"
  done

  kubectl wait --for=condition=Ready pods --all --all-namespaces --timeout=300s

  # TODO: write more tests here ...
}

uninstall() {
  for CHART in "${UPDATED_CHARTS[@]}";
  do
      IFS='/' read -ra CHART_ARRAY <<< "$CHART"
      CHART_NAME=${CHART_ARRAY[1]}
      if helm list -A --deployed -d | grep "$CHART_NAME" >/dev/null 2>&1;then
        helm --namespace "$NAMESPACE" delete "$CHART_NAME"  
      fi
    done
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
