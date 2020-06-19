# install  nfs.service

```
systemctl stop firewalld.service
yum -y install nfs-utils rpcbind nfs-common
mkdir -p /data/nfs_data
chmod 755 /data/nfs_data

cat > /etc/exports <<EOF
/data/nfs_data  *(rw,sync,no_root_squash)
EOF

systemctl enable rpcbind.service
systemctl enable nfs.service
systemctl start rpcbind.service
systemctl start nfs.service

kubectl create -f 1-nfs-storageclass/

kubectl get sc

kubectl patch storageclass course-nfs-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

# install prometheus+node-exporter+kube-state-metrics

```
kubectl create -f 2-prometheus/
```

# install grafana

```
kubectl create -f 3-grafana/
```

# add kubernetes plugins

```
kubectl exec  -it grafana-core-6bf7b7b878-c9mtt -n monitor-metrics /bin/sh

grafana-cli plugins install grafana-kubernetes-app

kubectl delete  pods grafana-655d56d554-8clxn -n monitor-metrics

kubectl delete -f grafana-svc.yaml
kubectl create -f grafana-svc.yaml
```

login grafana dashboard

enable plugins kubernetes

add datasource

URL http://prometheus:9090 or http://prometheus.monitor-metrics.svc:9090

add kubernetes-cluster

Prometheus Read   Datasource Prometheus

**Name kubernetes**

URL https://10.127.0.16:6443  or  https://10.10.0.1 or https://kubernetes.default.svc

--Access Server(default)
--Selected TLS Client Auth

```
--kubelet-client-certificate=/k8s/kubernetes/ssl/server.pem
--kubelet-client-key=/k8s/kubernetes/ssl/server-key.pem
```

save

Manage Dashboards import 315
