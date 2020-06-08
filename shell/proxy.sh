#!/bin/bash
set -e

HOSTNAME=${1:-"`hostname`"}

cat <<EOF >/k8s/kubernetes/cfg/kube-proxy.conf
KUBE_PROXY_OPTS="--logtostderr=true \\
--v=2 \\
--config=/k8s/kubernetes/cfg/kube-proxy-config.yml"
EOF

cat <<EOF >/k8s/kubernetes/cfg/kube-proxy-config.yml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
address: 0.0.0.0 # 监听地址
metricsBindAddress: 0.0.0.0:10249 # 监控指标地址,监控获取相关信息 就从这里获取
clientConnection:
  kubeconfig: /k8s/kubernetes/cfg/kube-proxy.kubeconfig # 读取配置文件
hostnameOverride: ${HOSTNAME} # 注册到k8s的节点名称唯一
clusterCIDR: 10.10.0.0/16 # service IP范围
mode: iptables # 使用iptables模式

# 使用 ipvs 模式
#mode: ipvs # ipvs 模式
#ipvs:
#  scheduler: "rr"
#iptables:
#  masqueradeAll: true
EOF

cat <<EOF >/usr/lib/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Proxy
After=network.target

[Service]
EnvironmentFile=-/k8s/kubernetes/cfg/kube-proxy.conf
ExecStart=/k8s/kubernetes/bin/kube-proxy \$KUBE_PROXY_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-proxy
systemctl start kube-proxy

sleep 10
journalctl -u kube-proxy -n 20 --no-pager
systemctl status kube-proxy
