# Secure your application on SUSE CaaS Platform with Cilium

![](susecon2020.png)

## Requirements

A laptop with:
* 4 Cores minimum
* 8GB RAM
* 40GB Free disk space

## Deploy

### Prereq

```bash
zypper ar http://download.opensuse.org/repositories/devel:/languages:/go/openSUSE_Leap_15.1/devel:languages:go.repo
zypper ar http://download.opensuse.org/repositories/systemsmanagement:/terraform/openSUSE_Leap_15.1/systemsmanagement:terraform.repo
zypper ar https://download.opensuse.org/repositories/devel:/kubic/openSUSE_Leap_15.1/devel:kubic.repo
zypper --gpg-auto-import-keys in -y libvirt terraform terraform-provider-libvirt go1.14 git helm curl mariadb-client
systemctl enable --now libvirtd
```

```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.16.2/bin/linux/amd64/kubectl
chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl
```

Add the content of `misc/.bashrc` to your `~/.bashrc`

### Deploy cluster

1. Add registration key in `terraform-libvirt-tf/registration.auto.tfvars`
2. Add SSH public key in `authorized_keys` in `terraform-libvirt-tf/terraform.tfvars`
3. Change image

```bash
cd terraform-libvirt-tf/
terraform init
terraform apply -parallelism=1
```

### Build skuba

```bash
# git clone https://github.com/suse/skuba
# cd skuba/
# make
GO111MODULE=on go install -mod=vendor -ldflags "-X=github.com/SUSE/skuba/pkg/skuba.Version=1.2.2 -X=github.com/SUSE/skuba/pkg/skuba.BuildDate=20200416 -X=github.com/SUSE/skuba/pkg/skuba.Tag= -X=github.com/SUSE/skuba/pkg/skuba.ClosestTag=v1.2.2-3-gfcea4dae" -tags development ./cmd/...
rm -f /root/go/bin/kubectl-caasp
ln -s /root/go/bin/skuba /root/go/bin/kubectl-caasp
```

### CaaSP Cluster

```bash
skuba cluster init --control-plane 10.17.2.0 caasp-cluster/
cd caasp-cluster/
skuba node bootstrap --user sles --sudo --target 10.17.2.0 susecon-master-0 -v4
skuba node join --role worker --user sles --sudo --target 10.17.3.0 susecon-worker-0 -v4

cp ./admin.conf ~/.kube/config
```

After a few minutes, the cluster should look like this:

```bash
NAME                    STATUS   ROLES    AGE     VERSION
node/susecon-master-0   Ready    master   6m54s   v1.16.2
node/susecon-worker-0   Ready    <none>   4m49s   v1.16.2

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

### Upgrade cilium

```bash
kubectl delete -f caasp-cluster/addons/cilium/cilium.yaml
kubectl apply -f deployment/prereq/cilium.yaml
```

### Prerequisites

```bash
kubectl apply -f deployment/prereq
kubectl apply -f deployment/prereq/metrics-server
./deployment/manage_charts.sh template
./deployment/manage_charts.sh
```

Deploy our storage class and make sure it's ready
before deploying the other components:

```bash
kubectl -n kube-system apply -f deployment/templates/local-path-provisioner/templates/
kubectl -n kube-system wait --timeout=300s --for=condition=Ready po -l app.kubernetes.io/name=local-path-provisioner
```

### MariaDB

```bash
kubectl -n mariadb apply -f deployment/templates/mariadb/templates/
kubectl -n mariadb wait --timeout=300s --for=condition=Ready po -l app=mariadb
mysql -u root -h 10.17.3.0 -psusecon -P30006 < misc/mariadb.sql
```

### Charts

```bash
./deployment/manage_charts.sh deploy
```

### tblshoot

At the root of the repo run:

```bash
for e in $(ls ./tblshoot/overlays/); do kubectl kustomize "./tblshoot/overlays/$e" | kubectl apply -f -; done
```
