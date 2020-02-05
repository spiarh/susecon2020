#!/usr/bin/env bash

TEMPLATES_DIR="./templates"
CHARTS_DIR="./charts"
CHARTS=$(ls -p $CHARTS_DIR | grep '/' | sed 's/\///')

mkdir "$TEMPLATES_DIR"

for c in $CHARTS; do
  ns="$c"
  charts_path="$CHARTS_DIR/$c"
  values_path="$CHARTS_DIR/$c-values.yaml"
  if [[ "$c" == "grafana" ]] || [[ "$c" == "prometheus" ]]; then
    ns="monitoring"
  fi
  if [[ "$c" == "loki-stack" ]] || [[ "$c" == "loki" ]] || [[ "$c" == "promtail" ]] ; then
    ns="logging"
  fi
  if [[ "$c" == "hubble" ]]; then
    ns="kube-system"
  fi

  echo ">>> helm template --namespace "$ns" --values "$c-values.yaml" --name "$c" "$charts_path" --output-dir $TEMPLATES_DIR"
  helm template --namespace "$ns" --values "$values_path" --name "$c" "$charts_path" --output-dir $TEMPLATES_DIR
  rm -Rf "$c"
done
