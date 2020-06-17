kubectl create ns monitor-metrics

kubectl create -f ./kube-state-metrics
kubectl create -f ./node-exporter
kubectl create -f ./prometheus
