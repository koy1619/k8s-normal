ETCD_NAME=${1:-"etcd01"}
ETCD_IP=${2:-"127.0.0.1"}
ETCD_CLUSTER=${3:-"etcd01=https://127.0.0.1:2379"}

cat <<EOF >/k8s/etcd/cfg/etcd.conf
name: ${ETCD_NAME}
data-dir: /data/etcd
listen-peer-urls: https://${ETCD_IP}:2380
listen-client-urls: https://${ETCD_IP}:2379,https://127.0.0.1:2379

advertise-client-urls: https://${ETCD_IP}:2379
initial-advertise-peer-urls: https://${ETCD_IP}:2380
initial-cluster: ${ETCD_CLUSTER}
initial-cluster-token: etcd-cluster
initial-cluster-state: new

client-transport-security:
  cert-file: /k8s/kubernetes/ssl/server.pem
  key-file: /k8s/kubernetes/ssl/server-key.pem
  client-cert-auth: false
  trusted-ca-file: /k8s/kubernetes/ssl/ca.pem
  auto-tls: false

peer-transport-security:
  cert-file: /k8s/kubernetes/ssl/server.pem
  key-file: /k8s/kubernetes/ssl/server-key.pem
  client-cert-auth: false
  trusted-ca-file: /k8s/kubernetes/ssl/ca.pem
  auto-tls: false

debug: false
logger: zap
log-outputs: [stderr]
EOF

cat <<EOF >/usr/lib/systemd/system/etcd.service
[Unit]
Description=Etcd Server
Documentation=https://github.com/etcd-io/etcd
Conflicts=etcd.service
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
LimitNOFILE=65536
Restart=on-failure
RestartSec=5s
TimeoutStartSec=0
ExecStart=/k8s/etcd/bin/etcd --config-file=/k8s/etcd/cfg/etcd.conf

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd
systemctl restart etcd

