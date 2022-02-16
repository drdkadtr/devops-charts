#!/bin/bash

# Default helm args: https://helm.sh/docs/helm/helm_upgrade/
declare -a HELM_ARGS=(upgrade "--install")
if [[ -n "$force" ]]; then HELM_ARGS+=("--force"); fi
if [[ -n "$debug" ]]; then HELM_ARGS+=("--debug"); fi
if [[ -n "$dryrun" ]]; then HELM_ARGS+=("--dry-run"); fi
if [[ -n "$resetvalues" ]]; then HELM_ARGS+=("--reset-values"); fi
if [[ -n "$reusevalues" ]]; then HELM_ARGS+=("--reuse-values"); fi

# Cluster role binding functions
clusterrolebinding_create(){
    if kubectl get clusterrolebinding cluster-admin-binding > /dev/null 2>&1; then
        kubectl delete clusterrolebinding cluster-admin-binding
    fi
    kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user "ci"
}

clusterrolebinding_delete() {
    kubectl delete clusterrolebinding cluster-admin-binding
}

setup_namespace(){
    kubectl describe namespace "$NAMESPACE" || kubectl create namespace "$NAMESPACE"
}

delete_namespace(){
    kubectl delete namespace "$NAMESPACE"
}

context_workspace_check() {
    CURRENT_CONTEXT=$(kubectl config current-context)
    CONTEXT_CLUSTER_NAME=$(kubectl config view -o jsonpath='{.contexts[?(@.name == '\""$CURRENT_CONTEXT"\"' )].context.cluster}')
    SERVER=$(kubectl config view -o jsonpath='{.clusters[?(@.name == '\""$CONTEXT_CLUSTER_NAME"\"' )].cluster.server}')

    if [[ -z ${CURRENT_CONTEXT} ]]; then
        echo "Error reading current context"
    fi

    if [[ -z ${SERVER} ]]; then
        echo "Error reading current server from context"
    fi
}

helm_v3_check() {
    if ! [ "$(command -v helm)" ]; then
        echo 'Error: helm is not installed.'
        exit 1
    fi
    # Check for version v3, without exit on error
    set +e
    helmVersion=$(helm version --client --short)
    set -e
    minorPatchPattern="[0-9]+.[0-9]+"
    if [[ "$helmVersion" =~ 'v3.'+$minorPatchPattern ]]; then
        echo "Helm v3 found ($helmVersion). Proceeed."
    elif [[ "$helmVersion" =~ 'v2.'+$minorPatchPattern ]]; then
        echo "Error. Helm v3 required, but v2 is found as default ($helmVersion). Exit."
        exit 1
    else
        echo "Error detecting helm version ($helmVersion). Helm v3 required. Exit."
        exit 1
    fi
}

helm_repo_update() {
    helm repo add "${1}" "${2}"
    helm repo update
}
