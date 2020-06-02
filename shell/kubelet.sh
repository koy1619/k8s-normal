#!/bin/bash

DNS_SERVER_IP=${1:-"10.10.0.2"}
HOSTNAME=${2:-"`hostname`"}
CLUETERDOMAIN=${3:-"cluster.local"}

cat <<EOF >/k8s/kubernetes/cfg/kubelet.conf
KUBELET_OPTS="--logtostderr=true \\
--v=2 \\
--hostname-override=${HOSTNAME} \\
--kubeconfig=/k8s/kubernetes/cfg/kubelet.kubeconfig \\
--bootstrap-kubeconfig=/k8s/kubernetes/cfg/bootstrap.kubeconfig \\
--config=/k8s/kubernetes/cfg/kubelet-config.yml \\
--cert-dir=/k8s/kubernetes/ssl \\
--network-plugin=cni \\
--cni-conf-dir=/etc/cni/net.d \\
--cni-bin-dir=/opt/cni/bin \\
--pod-infra-container-image=system386/pause-amd64:3.2"
EOF

cat <<EOF >/k8s/kubernetes/cfg/kubelet-config.yml
kind: KubeletConfiguration # 使用对象
apiVersion: kubelet.config.k8s.io/v1beta1 # api版本
address: 0.0.0.0 # 监听地址
port: 10250 # 当前kubelet的端口
readOnlyPort: 10255 # kubelet暴露的端口
cgroupDriver: cgroupfs # 驱动，要与docker info显示的驱动一致
clusterDNS:
  - ${DNS_SERVER_IP}
clusterDomain: ${CLUETERDOMAIN}  # 集群域
failSwapOn: false # 关闭swap

# 身份验证
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 2m0s
    enabled: true
  x509:
    clientCAFile: /k8s/kubernetes/ssl/ca.pem

# 授权
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 5m0s
    cacheUnauthorizedTTL: 30s

# Node 资源保留
evictionHard:
  imagefs.available: 15%
  memory.available: 1G
  nodefs.available: 10%
  nodefs.inodesFree: 5%
evictionPressureTransitionPeriod: 5m0s

# 镜像删除策略
imageGCHighThresholdPercent: 85
imageGCLowThresholdPercent: 80
imageMinimumGCAge: 2m0s

# 旋转证书
rotateCertificates: true # 旋转kubelet client 证书
featureGates:
  RotateKubeletServerCertificate: true
  RotateKubeletClientCertificate: true

maxOpenFiles: 1000000
maxPods: 110
EOF

cat <<EOF >/usr/lib/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
After=docker.service
Requires=docker.service

[Service]
EnvironmentFile=-/k8s/kubernetes/cfg/kubelet.conf
ExecStart=/k8s/kubernetes/bin/kubelet \$KUBELET_OPTS
Restart=on-failure
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet

