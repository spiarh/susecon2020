---
title: 'Secure your application on SUSE CaaS Platform with Cilium'
document: deployment
author:
    - Ludovic Cavajani
    - Paul Gonin
---


Introduction
===========================

The objective of this document is to deploy the following workloads
on top of `SUSE CaaS Platform` so we can then have fun doing the Lab !

* Envoy as a frontend proxy to access applications in the cluster
* MariaDB database to store data for the web application
* Prestashop application as an online store
* NextCloud application as a collaboration tool
* Prometheus/Grafana for monitoring
* Loki/Grafana for logging

![](susecon2020.png)

The services are accessible at the following URL:
* https://nextcloud.susecon.lab
* https://prestashop.susecon.lab
* https://hubble.susecon.lab

Default password: `nextcloud` is used everywhere (can be changed):
* Linux: sles/susecon
* Nextcloud: admin/susecon
* Prestashop: susecon@suse.com/susecon
* Grafana: admin/susecon
* MariaDB: root/susecon, nextcloud/susecon, prestashop/susecon


Requirements
========================

If you want to deploy a local libvirt cluster, it's recommended
to have the following hardware:
* 4 Cores minimum
* 8GB RAM
* 40GB Free disk space


If you deploy the cluster by your own means, the setup **must** be:
* 1 master minimum
* 1 worker (2cpu/4gb) **extremely recommended**, it is possible to deploy the workloads
with several workers but there is a risk regarding storage. The storage class
provides volumes from local storage so in case a pod with data is deleted
and recreated to an other node, the data will be "logs" for the running pod.


Nodes must have the following port open:
* 80/tcp
* 443/tcp
* 3306/tcp
* 9901/tcp


Deploy cluster with libvirt (OPTIONAL)
========================

This section can be executed if you don't have a SUSE CaaSP Platform
cluster already running otherwise, you can skip this section and
use an existing cluster.

```bash
sudo zypper ar http://download.opensuse.org/repositories/devel:/languages:/go/openSUSE_Leap_15.1/devel:languages:go.repo
sudo zypper ar http://download.opensuse.org/repositories/systemsmanagement:/terraform/openSUSE_Leap_15.1/systemsmanagement:terraform.repo
sudo zypper --gpg-auto-import-keys in -y libvirt terraform terraform-provider-libvirt go1.14 make
sudo systemctl enable --now libvirtd
```


### Prereq

1. Change registration key variable `caasp_registry_code` in `terraform-libvirt-tf/registration.auto.tfvars`
2. Add SSH public key variable `authorized_keys` in `terraform-libvirt-tf/terraform.tfvars`
3. Change image variable `image_uri` in `terraform-libvirt-tf/terraform.tfvars`
4. Change password variable `password` in `terraform-libvirt-tf/terraform.tfvars`

```bash
cd terraform-libvirt-tf/
terraform init
terraform plan
terraform apply -parallelism=1
```

:warning: user has to be in `libvirt` group


### Build skuba

```bash
$ git clone https://github.com/suse/skuba
$ cd skuba/
$ git checkout release-caasp-4.1.2+backport.1
$ make release
GO111MODULE=on go install -mod=vendor -ldflags "-X=github.com/SUSE/skuba/pkg/skuba.Version=1.2.2 -X=github.com/SUSE/skuba/pkg/skuba.BuildDate=20200416 -X=github.com/SUSE/skuba/pkg/skuba.Tag= -X=github.com/SUSE/skuba/pkg/skuba.ClosestTag=v1.2.2-3-gfcea4dae" -tags development ./cmd/...
$ rm -f ~/go/bin/kubectl-caasp
$ ln -s ~/go/bin/skuba /root/go/bin/kubectl-caasp
```


### CaaSP Cluster

It's absolutely not a problem to use the officially supported RPMs.
Building `skuba` from sources is just way to cover more platforms.

```bash
rm -R caasp-cluster/
~/go/bin/skuba cluster init --control-plane 10.17.2.0 caasp-cluster
cd caasp-cluster/
~/go/bin/skuba node bootstrap --user sles --sudo --target 10.17.2.0 susecon-master-0 -v4
~/go/bin/skuba node join --role worker --user sles --sudo --target 10.17.3.0 susecon-worker-0 -v4
```

If you want to make the kubeconfig globally available:

```
cp ./admin.conf ~/.kube/config
```

Or just in the current shell

```
export KUBECONFIG=$(readlink -e ./admin.conf)
```

After a few minutes, the cluster should look like this:

```bash
$ kubectl get nodes
NAME                    STATUS   ROLES    AGE     VERSION
node/susecon-master-0   Ready    master   6m54s   v1.16.2
node/susecon-worker-0   Ready    <none>   4m49s   v1.16.2

$ kubectl -n kube-system get po
NAMESPACE     NAME                                           READY   STATUS    RESTARTS   AGE
kube-system   pod/cilium-l95nl                               1/1     Running   0          4m49s
kube-system   pod/cilium-nhnb5                               1/1     Running   0          6m35s
kube-system   pod/cilium-operator-97cfc4756-s82b6            1/1     Running   0          6m35s
kube-system   pod/coredns-88dfb894c-bz5h6                    1/1     Running   0          6m35s
kube-system   pod/coredns-88dfb894c-m8flv                    1/1     Running   0          6m35s
kube-system   pod/etcd-susecon-master-0                      1/1     Running   0          5m34s
kube-system   pod/kube-apiserver-susecon-master-0            1/1     Running   0          5m38s
kube-system   pod/kube-controller-manager-susecon-master-0   1/1     Running   0          5m38s
kube-system   pod/kube-proxy-ctwfj                           1/1     Running   0          6m35s
kube-system   pod/kube-proxy-j6rs5                           1/1     Running   0          4m49s
kube-system   pod/kube-scheduler-susecon-master-0            1/1     Running   0          5m42s
kube-system   pod/kured-cftmq                                1/1     Running   0          2m38s
kube-system   pod/kured-h6rth                                1/1     Running   0          4m54s
kube-system   pod/oidc-dex-799996b768-9qpb8                  1/1     Running   0          6m35s
kube-system   pod/oidc-dex-799996b768-gkgc9                  1/1     Running   0          6m35s
kube-system   pod/oidc-dex-799996b768-rlfp4                  1/1     Running   0          6m35s
kube-system   pod/oidc-gangway-5f7496c7df-c8v4x              1/1     Running   0          6m35s
kube-system   pod/oidc-gangway-5f7496c7df-f8khk              1/1     Running   0          6m35s
kube-system   pod/oidc-gangway-5f7496c7df-pzg5r              1/1     Running   0          6m35s
```


Deploy platform
========================

## Prerequisites

```bash
zypper in -y git curl mariadb-client jq
```

* helm 2

There is currently an issue with helm3 and templating so we use
helm 2 but without Tiller.

```
curl -OL https://get.helm.sh/helm-v2.16.6-linux-amd64.tar.gz
tar zxf helm-v2.16.6-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm && chmod +x /usr/local/bin/helm
rm -Rf helm-v2.16.6-linux-amd64.tar.gz linux-amd64/
```

* kubectl

```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.16.2/bin/linux/amd64/kubectl
chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl
```

* Add the content of `misc/.bashrc` to your `~/.bashrc`


## Platform prerequisites

### Disable reboots

In order to avoid any disturbance, we need to disable node reboots:

```bash
kubectl -n kube-system annotate ds kured weave.works/kured-node-lock='{"nodeID":"manual"}'
```


### Upgrade cilium

At this time, SUSE CaaSP Platform `4.2.0` ships version `1.5.3`
which does not provide all the features require for the Lab.
Hopefully, Cilium `1.6.6` will be introduced in version `4.3.0`, thus
this step will not be required anymore.

:warning: Replace `caasp-cluster` with the path to you cluster files.

```bash
kubectl delete -f caasp-cluster/addons/cilium/cilium.yaml
kubectl apply -f deployment/prereq/cilium.yaml
```

:warning: Restarting `crio` service might be necessary if pod can't start

Before deploying the Helm charts, we need to create some
prerequisites in the clusters like namespaces etc. `metrics-servers`
is deployed for convenience.

```bash
kubectl apply -f deployment/prereq
kubectl apply -f deployment/prereq/metrics-server
```

Now we can use the command `top` with `kubectl`:

```bash
$ kubectl top node
NAME               CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
susecon-master-0   161m         8%     1487Mi          38%       
susecon-worker-0   33m          1%     710Mi           18%
```


### Parametrize charts

#### Passwords (Recommended)

Depending on your setup if the cluster is not fully isolated, it's
recommended to change the passwords.

```bash
export PASSWORD=myNewSecuredPassword
sed -i "s|password:.*|password: $PASSWORD|g" deployment/charts/mariadb-values.yaml deployment/charts/nextcloud-values.yaml deployment/charts/prestashop-values.yaml
sed -i "s|prestashopPassword:.*|prestashopPassword: $PASSWORD|g" deployment/charts/prestashop-values.yaml
sed -i "s|susecon|$PASSWORD|g" misc/mariadb.sql
```


#### Render charts

We can now render the manifests from the helm charts:

```bash
./deployment/manage_charts.sh template
```


### Storage class

The `local-path-provisioner` allows one to use local storage
behind a storage class.

Deploy our storage class and make sure it's ready
before deploying the other components:

```bash
kubectl -n kube-system apply -f deployment/templates/local-path-provisioner/templates/
kubectl -n kube-system wait --timeout=300s --for=condition=Ready po -l app.kubernetes.io/name=local-path-provisioner
```

Wait for something like:

> pod/local-path-provisioner-66469b44f-m78tl condition met


### Prepare external services exposition

We need to expose our services externally using `Envoy`. To do so
we have to select a node in the cluster that we will access using
a service with `externalIps` configure (this is done later in the documentation).

For now, we need to select a node and create `/etc/hosts` entries.

Considering the following cluster:

```bash
$ kubectl get nodes 
NAME                 STATUS   ROLES    AGE   VERSION
susecon-master-0   Ready    master   11d   v1.16.2
susecon-worker-0   Ready    <none>   11d   v1.16.2
```

And we want to expose Envoy as the frontend proxy on `susecon-worker-0`,
we can retrieve its IP:

```bash
$ kubectl get node susecon-worker-0 -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}'
10.17.3.0
```

Add entries in `/etc/hosts` so we can use fqdn during the labs,
envoy configuration depends on it !

```bash
$ export EXPOSE_IP=$(kubectl get node susecon-worker-0 -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
$ echo $EXPOSE_IP 
10.17.3.0
$ echo "$EXPOSE_IP envoy prestashop mariadb nextcloud grafana prometheus hubble prestashop.susecon.lab mariadb.susecon.lab nextcloud.susecon.lab grafana.susecon.lab prometheus.susecon.lab hubble.susecon.lab envoy.susecon.lab" | sudo tee -a /etc/hosts
$ sudo cat /etc/hosts | grep susecon
10.17.3.0 envoy prestashop mariadb nextcloud grafana prometheus hubble prestashop.susecon.lab mariadb.susecon.lab nextcloud.susecon.lab grafana.susecon.lab prometheus.susecon.lab hubble.susecon.lab envoy.susecon.lab
```

:warning: If the node is running on OpenStack with a **floating IP**, you have
to use the **floating IP** associated to the node !


## MariaDB

MariaDB is the storage backend for prestashop and nextcloud so it has to
be deployed first.

Replace `$PASSWORD` with correct password.

```bash
$ echo $PASSWORD
myNewSecuredPassword
$ kubectl -n mariadb apply -f deployment/templates/mariadb/templates/
$ kubectl -n mariadb wait --timeout=600s --for=condition=Ready po -l app=mariadb
```

Wait for:

> pod/mariadb-0 condition met

Create database and users:

```bash
$ mysql -u root -h mariadb.susecon.lab -p$PASSWORD -P30006 < misc/mariadb.sql
$ mysql -u root -h mariadb.susecon.lab -p$PASSWORD -P30006 -e "SHOW DATABASES;"
+--------------------+
| Database           |
+--------------------+
| information_schema |
| my_database        |
| mysql              |
| nextcloud          |
| performance_schema |
| prestashop         |
| test               |
+--------------------+
```


## Charts

It's time to deploy the components of our platform.

```bash
./deployment/manage_charts.sh deploy
```

After a few minutes, everythin should be running and Ready:

```bash
$ kubectl get po -A
NAMESPACE     NAME                                             READY   STATUS    RESTARTS   AGE
envoy         envoy-6b44496f9f-5rjpt                           1/1     Running   0          5m33s
kube-system   cilium-5jwx9                                     1/1     Running   0          55m
kube-system   cilium-7fq69                                     1/1     Running   1          53m
kube-system   cilium-operator-6bb7bc7ffb-wl9kt                 1/1     Running   0          55m
kube-system   cilium-wflxr                                     1/1     Running   0          55m
kube-system   cilium-zttrc                                     1/1     Running   0          53m
kube-system   coredns-7ffbb88dbb-2pzj5                         1/1     Running   0          11d
kube-system   coredns-7ffbb88dbb-xbkbk                         1/1     Running   0          11d
kube-system   etcd-master-0                                    1/1     Running   0          11d
kube-system   hubble-6lrd9                                     1/1     Running   0          5m19s
kube-system   hubble-dhwqt                                     1/1     Running   0          5m19s
kube-system   hubble-f9skj                                     1/1     Running   0          5m19s
kube-system   hubble-k2k7d                                     1/1     Running   0          5m19s
kube-system   hubble-ui-5f9fc85849-hnhkk                       1/1     Running   0          5m19s
kube-system   kube-apiserver-master-0                          1/1     Running   0          11d
kube-system   kube-controller-manager-master-0                 1/1     Running   0          11d
kube-system   kube-proxy-269xj                                 1/1     Running   0          11d
kube-system   kube-proxy-96gxl                                 1/1     Running   0          11d
kube-system   kube-proxy-l8gz7                                 1/1     Running   0          11d
kube-system   kube-proxy-lkvx8                                 1/1     Running   0          11d
kube-system   kube-scheduler-master-0                          1/1     Running   0          11d
kube-system   kured-8qsb4                                      1/1     Running   0          5d4h
kube-system   kured-972bd                                      1/1     Running   0          5d4h
kube-system   kured-rkl6v                                      1/1     Running   0          5d4h
kube-system   kured-t68g5                                      1/1     Running   0          5d4h
kube-system   local-path-provisioner-66469b44f-v7dwh           1/1     Running   0          22m
kube-system   metrics-server-744695bbd5-nxs4k                  1/1     Running   0          51m
kube-system   oidc-dex-767dc6847b-4sd82                        1/1     Running   0          5d4h
kube-system   oidc-dex-767dc6847b-f4jw8                        1/1     Running   0          5d4h
kube-system   oidc-dex-767dc6847b-kx9cr                        1/1     Running   0          5d4h
kube-system   oidc-gangway-c4f5b57c9-68c2q                     1/1     Running   0          5d4h
kube-system   oidc-gangway-c4f5b57c9-jv4lk                     1/1     Running   0          5d4h
kube-system   oidc-gangway-c4f5b57c9-xxsc4                     1/1     Running   0          5d4h
logging       loki-0                                           1/1     Running   0          5m10s
logging       promtail-97dqn                                   1/1     Running   0          4m44s
logging       promtail-cnqv8                                   1/1     Running   0          4m44s
logging       promtail-jd5xp                                   1/1     Running   0          4m44s
logging       promtail-rcmq9                                   1/1     Running   0          4m44s
mariadb       mariadb-0                                        2/2     Running   0          14m
monitoring    grafana-5648597896-jwj8m                         2/2     Running   0          5m22s
monitoring    prometheus-kube-state-metrics-6787fbdd45-h654j   1/1     Running   0          4m57s
monitoring    prometheus-server-85bfb46f4-xffr9                2/2     Running   0          4m50s
nextcloud     nextcloud-6746dcd57-qq2j4                        1/1     Running   1          5m5s
prestashop    prestashop-787ff96788-rtnmf                      2/2     Running   0          5m2s
```

Enable `SSL` everywhere in `prestashop` to avoid redirect loops
between the pod and envoy:

```bash
$ mysql -u root -h mariadb.susecon.lab -p$PASSWORD -P30006 prestashop -e "UPDATE ps_configuration SET value=1 WHERE name='PS_SSL_ENABLED';"
$ mysql -u root -h mariadb.susecon.lab -p$PASSWORD -P30006 prestashop -e "UPDATE ps_configuration SET value=1 WHERE name='PS_SSL_ENABLED_EVERYWHERE';"
```

## Envoy

Expose envoy externally on the IP address we retrieved before:

Replace

```bash
$ echo $EXPOSE_IP
10.17.3.0
$ kubectl -n envoy patch svc envoy -p "{\"spec\":{\"externalIPs\":[\"$EXPOSE_IP\"]}}"
service/envoy patched
```

You can verify the value with:

```bash
$ kubectl -n envoy get svc envoy -ojsonpath='{.spec.externalIPs[]}'
10.17.3.0
```


## tblshoot pods

At the root of the repo run:

```bash
for e in $(ls ./tblshoot/overlays/); do kubectl kustomize "./tblshoot/overlays/$e" | kubectl apply -f -; done
```

The `tblshoot` pods should look like this:

```
$ kubectl get po -A|grep tblshoot
envoy         tblshoot-999fb7455-bcmwf                         1/1     Running   0          71s
kube-system   tblshoot-668898997c-xkcrs                        1/1     Running   0          68s
logging       tblshoot-loki-764bcbdb5c-kcrmr                   1/1     Running   0          66s
logging       tblshoot-promtail-864bdc75bb-wldfh               1/1     Running   0          59s
mariadb       tblshoot-7c54df6d78-44kkb                        1/1     Running   0          65s
monitoring    tblshoot-grafana-79b6db99d-pnrxj                 1/1     Running   0          70s
monitoring    tblshoot-prometheus-bd7fbcc94-n2b5j              1/1     Running   0          61s
nextcloud     tblshoot-8d4dcdd65-x9phb                         1/1     Running   0          63s
prestashop    tblshoot-5ffb7d8769-nd5zm                        1/1     Running   0          62s
tblshoot      tblshoot-65b8bdc489-bphlb                        1/1     Running   0          57s
```


**Congrats !!!**

You should now have access to the URL mentionned in introduction.


You can now proceed to the lab [Secure your application on SUSE CaaS Platform with Cilium](./INSTRUCTIONS.md)
