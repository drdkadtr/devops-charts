#!/bin/bash

# About: install and test local chart before release

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

      CHART_VALUES_FILE="$CHART_NAME.test.yaml"
      if [[ -f "$CHART_VALUES_FILE" ]]; then HELM_VALUES+=(-f "$CHART_VALUES_FILE"); fi

      helm "${HELM_ARGS[@]}" "${CHART_NAME}" "${CHART}" \
        --create-namespace \
        --namespace="$NAMESPACE" "${HELM_VALUES[@]}"

      # FIXME: second run waits forever
      # kubectl -n "$NAMESPACE" wait --for=condition=Ready pods --all --timeout=300s
      sleep 1
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
