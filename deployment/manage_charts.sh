#!/usr/bin/env bash

set -euo pipefail

DIR="$( cd "$( dirname "$0" )" && pwd )"

TEMPLATES_DIR="$DIR/templates"
CHARTS_DIR="$DIR/charts"
CHARTS=$(ls "$CHARTS_DIR" | grep -v yaml)

mkdir -p "$TEMPLATES_DIR"

for c in $CHARTS; do
  # NAMESPACES
  ns="$c"
  charts_path="$CHARTS_DIR/$c"
  values_path="$CHARTS_DIR/$c-values.yaml"
  rendered_files_dir="$TEMPLATES_DIR/$c/templates"

  if [[ "$c" == "grafana" ]] || [[ "$c" == "prometheus" ]]; then
    ns="monitoring"
  fi

  if [[ "$c" == "loki-stack" ]] || [[ "$c" == "loki" ]] || [[ "$c" == "promtail" ]] ; then
    ns="logging"
  fi

  if [[ "$c" == "hubble" ]] || [[ "$c" == "local-path-provisioner" ]]; then
    ns="kube-system"
  fi

  # ACTIONS
  if [[ "$1" == "template" ]]; then
    echo "rm -Rvf $rendered_files_dir"
    rm -Rvf "$rendered_files_dir"
    echo ">>> helm template --namespace $ns --values $c-values.yaml --name $c $charts_path --output-dir $TEMPLATES_DIR"
    helm template --namespace "$ns" --values "$values_path" --name "$c" "$charts_path" --output-dir "$TEMPLATES_DIR"
  fi

  if [[ "$1" == "deploy" ]]; then
    echo ">>> kubectl --namespace $ns apply -f $rendered_files_dir"
    kubectl --namespace "$ns" apply -f "$rendered_files_dir"
  fi

  if [[ "$1" == "destroy" ]]; then
    echo ">>> kubectl --namespace $ns delete -f $rendered_files_dir"
    kubectl --namespace "$ns" delete --ignore-not-found=true -f "$rendered_files_dir"
  fi
done
