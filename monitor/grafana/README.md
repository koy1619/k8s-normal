```
kubectl create -f ./

kubectl exec  -it grafana-core-6bf7b7b878-c9mtt -n lens-metrics /bin/sh

grafana-cli plugins install grafana-kubernetes-app

kubectl delete  pods grafana-655d56d554-8clxn lens-metrics
```

login grafana dashboard

enable plugins kubernetes

add datasource

URL http://prometheus

add kubernetes-cluster 

Prometheus Read   Datasource Prometheus

URL https://kubernetes

--Access Server(default)
--Selected TLS Client Auth


--kubelet-client-certificate=/k8s/kubernetes/ssl/server.pem
--kubelet-client-key=/k8s/kubernetes/ssl/server-key.pem

save

Manage Dashboards import 315
