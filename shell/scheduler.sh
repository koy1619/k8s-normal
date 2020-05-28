#!/bin/bash

MASTER_ADDRESS=${1:-"127.0.0.1"}

cat <<EOF >/k8s/kubernetes/cfg/kube-scheduler
KUBE_SCHEDULER_k8sS="--logtostderr=true \\
--v=2 \\
--master=${MASTER_ADDRESS}:8080 \\
--address=0.0.0.0 \\
--leader-elect"
EOF

cat <<EOF >/usr/lib/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/k8s/kubernetes/cfg/kube-scheduler
ExecStart=/k8s/kubernetes/bin/kube-scheduler \$KUBE_SCHEDULER_k8sS
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-scheduler
systemctl restart kube-scheduler

