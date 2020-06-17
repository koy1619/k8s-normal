wget https://raw.githubusercontent.com/redhatxl/k8s-prometheus-grafana/master/node-exporter.yaml

for file in configmap.yaml prometheus.deploy.yml prometheus.svc.yml rbac-setup.yaml;do wget https://raw.githubusercontent.com/redhatxl/k8s-prometheus-grafana/master/prometheus/$file;done

for file in grafana-deploy.yaml grafana-ing.yaml grafana-svc.yaml;do wget https://raw.githubusercontent.com/redhatxl/k8s-prometheus-grafana/master/grafana/$file;done

