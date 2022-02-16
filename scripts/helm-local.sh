#!/bin/bash

# About: install and test local chart

set -e
set -x

# If BASEDIR is undefined, set it using git.
if [ -z "$BASEDIR" ] && git --version >/dev/null 2>&1; then
    BASEDIR=$(git rev-parse --show-toplevel)
    source "$BASEDIR"/scripts/constants.sh
fi

# Constants
UPDATED_CHARTS=$(ct list-changed --config ct.yaml)

install(){
  for CHART in "${UPDATED_CHARTS[@]}";
  do
      IFS='/' read -ra CHART_ARRAY <<< "$CHART"
      CHART_NAME=${CHART_ARRAY[1]}
      NAMESPACE="$CHART_NAME"
      HELM_VALUES=()
      CHART_OVERRIDE_FILE="$CHART_NAME.override.yaml"
      if [[ -f "$CHART_OVERRIDE_FILE" ]]; then HELM_VALUES+=(-f "$CHART_OVERRIDE_FILE"); fi
      helm "${HELM_ARGS[@]}" "${CHART_NAME}" "${CHART}" \
        --create-namespace \
        --namespace="$NAMESPACE" "${HELM_VALUES[@]}" --wait
      kubectl -n "$NAMESPACE" get all
      helm test "${CHART_NAME}" --namespace "$NAMESPACE"
  done
}

uninstall() {
  for CHART in "${UPDATED_CHARTS[@]}";
  do
      IFS='/' read -ra CHART_ARRAY <<< "$CHART"
      CHART_NAME=${CHART_ARRAY[1]}
      NAMESPACE="$CHART_NAME"
      if helm list -A --deployed -d | grep "$CHART_NAME" >/dev/null 2>&1;then
        helm --namespace "$NAMESPACE" delete "$CHART_NAME"
        delete_namespace "$NAMESPACE"
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
