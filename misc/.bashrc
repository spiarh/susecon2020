
function tblshoot-shell {
  local extra_label
  extra_label=""

  if [[ "$2" != "" ]]; then
    extra_label=",$2"
  fi

  kubectl -n "$1" exec -ti "$(kubectl -n "$1" get po -l role=tblshoot"$extra_label" -ojsonpath='{.items[0].metadata.name}')" sh
}

alias deploy-tblshoot-pods='for e in $(ls ./tblshoot/overlays/); do kubectl kustomize "./tblshoot/overlays/$e" | kubectl apply -f -; done'

alias tblshoot-prometheus='tblshoot-shell monitoring app=prometheus'
alias tblshoot-grafana='tblshoot-shell monitoring app=grafana'
alias tblshoot-loki='tblshoot-shell logging app=loki'
alias tblshoot-promtail='tblshoot-shell logging app=promtail'
alias tblshoot-nextcloud='tblshoot-shell nextcloud app.kubernetes.io/instance=nextcloud'
alias tblshoot-prestashop='tblshoot-shell prestashop'
alias tblshoot-envoy='tblshoot-shell envoy'
alias tblshoot-mariadb='tblshoot-shell mariadb'
alias tblshoot-kube-system='tblshoot-shell kube-system'
alias tblshoot-tblshoot='tblshoot-shell tblshoot'
