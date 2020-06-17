kubectl create ns lens-metrics

kubectl create -f  prometheus-pvc.yaml

kubectl create -f  configmap.yaml
kubectl create -f  node-exporter.yaml
kubectl create -f  prometheus.deploy.yml
kubectl create -f  prometheus.svc.yml
kubectl create -f  rbac-setup.yaml
