#!/bin/bash
set -e

MASTER_ADDRESS=${1:-"192.168.0.216"}
ETCD_SERVERS=${2:-"http://127.0.0.1:2379"}

# 创建 kube-apiserver 日志存放目录
mkdir -p /var/log/kubernetes

# 创建 kube-apiserver 审计日志文件
touch /var/log/kubernetes/k8s-audit.log

cat <<EOF >/k8s/kubernetes/cfg/kube-apiserver
KUBE_APISERVER_OPTS="--logtostderr=false \\
--v=2 \\
--log-dir=/var/log/kubernetes \\
--etcd-servers=${ETCD_SERVERS} \\
--bind-address=0.0.0.0 \\
--secure-port=6443 \\
--advertise-address=${MASTER_ADDRESS} \\
--allow-privileged=true \\
--service-cluster-ip-range=10.10.0.0/16 \\
--enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota,NodeRestriction \\
--authorization-mode=RBAC,Node \\
--kubelet-https=true \\
--enable-bootstrap-token-auth=true \\
--token-auth-file=/k8s/kubernetes/cfg/token.csv \\
--service-node-port-range=30000-50000 \\
--kubelet-client-certificate=/k8s/kubernetes/ssl/server.pem \\
--kubelet-client-key=/k8s/kubernetes/ssl/server-key.pem \\
--tls-cert-file=/k8s/kubernetes/ssl/server.pem  \\
--tls-private-key-file=/k8s/kubernetes/ssl/server-key.pem \\
--client-ca-file=/k8s/kubernetes/ssl/ca.pem \\
--service-account-key-file=/k8s/kubernetes/ssl/ca-key.pem \\
--etcd-cafile=/k8s/kubernetes/ssl/ca.pem \\
--etcd-certfile=/k8s/kubernetes/ssl/server.pem \\
--etcd-keyfile=/k8s/kubernetes/ssl/server-key.pem \\
--requestheader-client-ca-file=/k8s/kubernetes/ssl/ca.pem \\
--requestheader-extra-headers-prefix=X-Remote-Extra- \\
--requestheader-group-headers=X-Remote-Group \\
--requestheader-username-headers=X-Remote-User \\
--proxy-client-cert-file=/k8s/kubernetes/ssl/metrics-server.pem \\
--proxy-client-key-file=/k8s/kubernetes/ssl/metrics-server-key.pem \\
--runtime-config=api/all=true \\
--audit-log-maxage=30 \\
--audit-log-maxbackup=3 \\
--audit-log-maxsize=100 \\
--audit-log-truncate-enabled=true \\
--audit-log-path=/var/log/kubernetes/k8s-audit.log"
EOF

cat <<EOF >/usr/lib/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/k8s/kubernetes/cfg/kube-apiserver
ExecStart=/k8s/kubernetes/bin/kube-apiserver \$KUBE_APISERVER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-apiserver
systemctl start kube-apiserver

sleep 10
journalctl -u kube-apiserver -n 20 --no-pager
systemctl status kube-apiserver
