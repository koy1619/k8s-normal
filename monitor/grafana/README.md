add kubernetes plugins

```

kubectl create -f  grafana-pvc.yaml

kubectl create -f  grafana-deploy.yaml
kubectl create -f  grafana-ing.yaml
kubectl create -f  grafana-svc.yaml


kubectl exec  -it grafana-core-6bf7b7b878-c9mtt -n monitor-metrics /bin/sh

grafana-cli plugins install grafana-kubernetes-app

kubectl delete  pods grafana-655d56d554-8clxn -n monitor-metrics

kubectl delete -f grafana-svc.yaml
kubectl create -f grafana-svc.yaml
```

login grafana dashboard

enable plugins kubernetes

add datasource

URL http://prometheus:9090

add kubernetes-cluster 

Prometheus Read   Datasource Prometheus

**Name kubernetes**

URL https://10.127.0.16:6443  or  https://10.10.0.1

--Access Server(default)
--Selected TLS Client Auth

```
--kubelet-client-certificate=/k8s/kubernetes/ssl/server.pem
--kubelet-client-key=/k8s/kubernetes/ssl/server-key.pem
```

save

Manage Dashboards import 315
