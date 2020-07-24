[root@k8s-master opt]$cat master_install.sh 
#!/usr/bin/env bash
set -e

cat >/etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF


k8s_version='1.18.0'
api_server='192.168.119.134'
service_cidr='10.96.0.0/12'
pod_network_cidr='10.244.0.0/16'

yum install -y kubelet-$k8s_version kubeadm-$k8s_version kubectl-$k8s_version

systemctl enable kubelet


kubeadm init \
--ignore-preflight-errors=all \  #将错误检查项忽略，仅用于测试
--apiserver-advertise-address=$api_server \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v$k8s_version \
--service-cidr=$service_cidr \
--pod-network-cidr=$pod_network_cidr

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get nodes
[root@k8s-master opt]$


[root@k8s-node-1 opt]$cat node_install.sh 
#!/usr/bin/env bash
set -e

cat >/etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF


k8s_version='1.18.0'

yum install -y kubelet-$k8s_version kubeadm-$k8s_version kubectl-$k8s_version

systemctl enable kubelet

[root@k8s-node-1 opt]$



$ kubeadm join 192.168.119.134:6443 --token ielou8.wlvhv8xtneuz050c \
    --discovery-token-ca-cert-hash sha256:c8bdc23ab043034a79d7315e1676dd9a115639f8e3ea96a39c7d20ff7c9666a2 

默认token有效期为24小时，当过期之后，该token就不可用了。这时就需要重新创建token，操作如下：

$ kubeadm token create --print-join-command



部署容器网络（CNI）
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
sed -i -r "s#quay.io/coreos/flannel:.*-amd64#lizhenliang/flannel:v0.11.0-amd64#g" kube-flannel.yml
kubectl apply -f kube-flannel.yml
kubectl get pods -n kube-system


###
#swapoff -a && kubeadm reset  && systemctl daemon-reload && systemctl restart kubelet  && iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
###
