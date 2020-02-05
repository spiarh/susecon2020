# Secure your application on SUSE CaaS Platform with Cilium

add jq

kubectl -n monitoring get po grafana-7dc5c88bcf-27q9r -ojson | jq '.metadata.labels,.spec.serviceAccount'

## Deploy cluster

skuba cluster init --control-plane 10.17.2.0 my-cluster
cd my-cluster/
skuba node bootstrap --user sles --sudo --target 10.17.2.0 susecon-master-0 -v4
skuba node join --role worker --user sles --sudo --target 10.17.3.0 susecon-worker-0 -v4

cp /root/libvirt/my-cluster/admin.conf ~/.kube/config


## MISC

* Script test instances are ready to be deploy (PING, SSH)
* Copy hosts in /etc/hosts for cluster nodes
* Create hosts in /etc/hosts for management node

```
10.17.3.0 prestashop nextcloud grafana prometheus prestashop.susecon.lab nextcloud.susecon.lab grafana.susecon.lab prometheus.susecon.lab
```

* Create diagram of deployment

* SSL certificates


```
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 1024 -out ca.crt

openssl genrsa -out server.key 4096
openssl req -x509 -new -nodes -key server.key -sha256 -days 1024 -out server.crt
```

kubectl apply -f ssl/envoy-tls.yaml

# Envoy

kubectl create ns envoy
helm template --namespace envoy --values envoy-values.yaml --name envoy envoy/ >envoy.yaml && kubectl -n envoy apply -f envoy.yaml


# Helm

kubectl apply -f ../tiller-rbac.yaml
helm init --service-account tiller --tiller-image registry.suse.com/caasp/v4/helm-tiller:2.16.1


## local-path-provisioner

kubectl apply -f local-path-provisioner-cr.yaml
helm upgrade --install --namespace kube-system local-path-provisioner --values local-path-provisioner-values.yaml local-path-provisioner/ 


## Prometheus / Grafana

helm upgrade --install --namespace monitoring prometheus --values prometheus-values.yaml prometheus/
helm upgrade --install --namespace monitoring grafana --values grafana-values.yaml grafana/


--> Add Metrics fetch

* Fetch metrics from prestashop, mariadb

### Dashboards


* Add mariadb dashboard

kubectl -n monitoring apply -f https://raw.githubusercontent.com/SUSE/caasp-monitoring/master/grafana-dashboards-caasp-cluster.yaml
kubectl -n monitoring apply -f https://raw.githubusercontent.com/SUSE/caasp-monitoring/master/grafana-dashboards-caasp-etcd-cluster.yaml
kubectl -n monitoring apply -f https://raw.githubusercontent.com/SUSE/caasp-monitoring/master/grafana-dashboards-caasp-namespaces.yaml
kubectl -n monitoring apply -f https://raw.githubusercontent.com/SUSE/caasp-monitoring/master/grafana-dashboards-caasp-nodes.yaml
kubectl -n monitoring apply -f https://raw.githubusercontent.com/SUSE/caasp-monitoring/master/grafana-dashboards-caasp-pods.yaml


## MariaDB

helm upgrade --install --namespace mariadb mariadb --values mariadb-values.yaml mariadb

CREATE DATABASE prestashop;
CREATE USER 'prestashop'@'%' IDENTIFIED BY 'prestashop';
GRANT ALL ON prestashop.* TO 'prestashop'@'%' WITH GRANT OPTION;


CREATE DATABASE nextcloud;
CREATE USER 'nextcloud'@'%' IDENTIFIED BY 'nextcloud';
GRANT ALL ON nextcloud.* TO 'nextcloud'@'%' WITH GRANT OPTION;

# Logging ?

# Prestashop

kubectl create ns prestashop
helm upgrade --install --namespace prestashop prestashop --values prestashop-values.yaml prestashop

helm template --namespace prestashop --values prestashop-values.yaml --name prestashop prestashop/ > prestashop.yaml
kubectl apply -n prestashop -f prestashop.yaml

# Nextcloud

kubectl create ns nextcloud
helm upgrade --install --namespace nextcloud nextcloud --values nextcloud-values.yaml nextcloud
helm template --namespace nextcloud --values nextcloud-values.yaml --name nextcloud nextcloud/ > nextcloud.yaml
kubectl apply -n nextcloud -f nextcloud.yaml


# Hubble

# 389ds


# Logging

kubectl create ns logging

kubectl apply -f kibana-serviceaccount.yaml





for e in $(ls overlays/); do kubectl kustomize "overlays/$e" | kubectl apply -f -; done


 curl -k https://prometheus.susecon.lab/api/v1/targets | jq '.data.activeTargets[].scrapeUrl'

Investigate 

  ingress:
#  - fromCIDR:
#    - 0.0.0.0/0
  - fromEndpoints:
    - {}
    toPorts:
    - ports:
      - port: "80"
        protocol: TCP
      - port: "443"
        protocol: TCP
      - port: "3306"
        protocol: TCP



kubectl -n envoy exec -ti "$(kubectl -n envoy get po -l role=tblshoot -ojsonpath='{.items[0].metadata.name}')" sh
/stats/prometheus
