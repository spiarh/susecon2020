# Notes


add jq

kubectl -n monitoring get po grafana-7dc5c88bcf-27q9r -ojson | jq '.metadata.labels,.spec.serviceAccount'

## TODO


* Create VMS with RPMs installed
* Create VM with container registry
* Script test instances are ready to be used for the lab (PING, SSH)
* Copy hosts in /etc/hosts for cluster/management nodes

```
10.17.3.0 hubble prestashop nextcloud grafana prometheus hubble prestashop.susecon.lab nextcloud.susecon.lab grafana.susecon.lab prometheus.susecon.lab
```

## MISC

* SSL certificates

```
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 1024 -out ca.crt

openssl genrsa -out server.key 4096
openssl req -x509 -new -nodes -key server.key -sha256 -days 1024 -out server.crt
```


for e in $(ls overlays/); do kubectl kustomize "overlays/$e" | kubectl apply -f -; done

* Get Prometheus targets

curl -k https://prometheus.susecon.lab/api/v1/targets | jq '.data.activeTargets[].scrapeUrl'

* Investigate

```yaml
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
```
