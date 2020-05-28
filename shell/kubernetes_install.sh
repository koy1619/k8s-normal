mkdir /opt/k8s-package
cd /opt/k8s-package
#wget https://dl.k8s.io/v1.18.2/kubernetes-client-linux-amd64.tar.gz
#wget https://dl.k8s.io/v1.18.2/kubernetes-server-linux-amd64.tar.gz
#wget https://dl.k8s.io/v1.18.2/kubernetes-node-linux-amd64.tar.gz


# 作者把二进制安装包上传到cdn上 https://cdm.yp14.cn/k8s-package/kubernetes-server-v1.18.2-linux-amd64.tar.gz

wget https://cdm.yp14.cn/k8s-package/kubernetes-server-v1.18.2-linux-amd64.tar.gz


tar zxvf kubernetes-server-v1.18.2-linux-amd64.tar.gz

# 进入解压出来二进制包bin目录
cd /opt/k8s-package/kubernetes/server/bin

# cpoy 执行文件到 /opt/kubernetes/bin 目录
cp -a kube-apiserver kube-controller-manager kube-scheduler kubectl kubelet kube-proxy /k8s/kubernetes/bin

# copy 执行文件到 k8s-master2 k8s-master3 机器 /opt/kubernetes/bin 目录
#scp kube-apiserver kube-controller-manager kube-scheduler kubectl kubelet kube-proxy root@k8s-node-1:/k8s/kubernetes/bin/
#scp kube-apiserver kube-controller-manager kube-scheduler kubectl kubelet kube-proxy root@k8s-node-2:/k8s/kubernetes/bin/
