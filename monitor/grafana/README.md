kubectl create -f ./

kubectl exec  -it grafana-core-6bf7b7b878-c9mtt -n lens-metrics /bin/sh

grafana-cli plugins install grafana-kubernetes-app

kubectl delete  pods grafana-655d56d554-8clxn lens-metrics
