

## Deploy cluster

skuba cluster init --control-plane 10.17.2.0 my-cluster
cd my-cluster/
skuba node bootstrap --user sles --sudo --target 10.17.2.0 susecon-master-0 -v4
skuba node join --role worker --user sles --sudo --target 10.17.3.0 susecon-worker-0 -v4

cp /root/libvirt/my-cluster/admin.conf ~/.kube/config


## MISC

* Script test instances are ready to be deploy (PING, SSH)
* Copy hosts in /etc/hosts
* Create diagram of deployment

* SSL certificates


# Helm

kubectl apply -f ../tiller-rbac.yaml
helm init --service-account tiller --tiller-image registry.suse.com/caasp/v4/helm-tiller:2.16.1


## local-path-provisioner

kubectl apply -f local-path-provisioner-cr.yaml
helm upgrade --install --namespace kube-system local-path-provisioner --values local-path-provisioner-values.yaml local-path-provisioner/ 


## Prometheus / Grafana

helm upgrade --install --namespace monitoring prometheus --values prometheus-values.yaml prometheus/
helm upgrade --install --namespace monitoring grafana --values grafana-values.yaml grafana/


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

helm upgrade --install --namespace prestashop prestashop --values prestashop-values.yaml prestashop

# Nextcloud

helm upgrade --install --namespace nextcloud nextcloud --values nextcloud-values.yaml nextcloud

# Hubble

# 389ds


