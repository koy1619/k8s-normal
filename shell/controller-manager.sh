#!/bin/bash

MASTER_ADDRESS=${1:-"127.0.0.1"}

cat <<EOF >/k8s/kubernetes/cfg/kube-controller-manager
KUBE_CONTROLLER_MANAGER_k8sS="--logtostderr=true \\
--v=2 \\
--master=${MASTER_ADDRESS}:8080 \\
--leader-elect=true \\
--bind-address=0.0.0.0 \\
--service-cluster-ip-range=10.10.0.0/16 \\
--cluster-name=kubernetes \\
--cluster-signing-cert-file=/k8s/kubernetes/ssl/ca.pem \\
--cluster-signing-key-file=/k8s/kubernetes/ssl/ca-key.pem  \\
--service-account-private-key-file=/k8s/kubernetes/ssl/ca-key.pem \\
--experimental-cluster-signing-duration=87600h0m0s \\
--feature-gates=RotateKubeletServerCertificate=true \\
--feature-gates=RotateKubeletClientCertificate=true \\
--allocate-node-cidrs=true \\
--cluster-cidr=10.20.0.0/16 \\
--root-ca-file=/k8s/kubernetes/ssl/ca.pem"
EOF

cat <<EOF >/usr/lib/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/k8s/kubernetes/cfg/kube-controller-manager
ExecStart=/k8s/kubernetes/bin/kube-controller-manager \$KUBE_CONTROLLER_MANAGER_k8sS
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-controller-manager
systemctl restart kube-controller-manager

