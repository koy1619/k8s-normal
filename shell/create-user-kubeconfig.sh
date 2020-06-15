#!/bin/bash
set -e

wget https://cdm.yp14.cn/k8s-package/k8s-1.17-bin/kubectl -O /opt/kubectl-1.7
chmod +x /opt/kubectl-1.7

kubectl_17=/opt/kubectl-1.7

USER_SSL_PATH="/root/yaml/create-user"
mkdir -p $USER_SSL_PATH
SSL_PATH="/k8s/kubernetes/ssl"

# 注意修改KUBE_APISERVER为你的API Server的地址

cd $USER_SSL_PATH

KUBE_APISERVER=$1
USER=$2
USER_SA=system:serviceaccount:default:${USER}
Authorization=$3
USAGE="USAGE: create-user.sh <api_server> <username> <clusterrole authorization>\n
Example: https://10.127.0.16:6443 brand"
CSR=`pwd`/user-csr.json
SSL_FILES=(ca-key.pem ca.pem ca-config.json)
CERT_FILES=(${USER}.csr $USER-key.pem ${USER}.pem)

if [[ $KUBE_APISERVER == "" ]]; then
   echo -e $USAGE
   exit 1
fi
if [[ $USER == "" ]];then
    echo -e $USAGE
    exit 1
fi

if [[ $Authorization == "" ]];then
    echo -e $USAGE
    exit 1
fi

# 创建用户的csr文件
function createCSR(){
cat>$CSR<<EOF
{
  "CN": "USER",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
# 替换csr文件中的用户名
sed -i "s/USER/$USER_SA/g" $CSR
}

function ifExist(){
if [ ! -f "$SSL_PATH/$1" ]; then
    echo "$SSL_PATH/$1 not found."
    exit 1
fi
}

function ifClusterrole(){
$kubectl_17 get clusterrole ${Authorization} &> /dev/null
if (( $? !=0 ));then
   echo "${Authorization} clusterrole there is no"
   exit 1
fi
}

# 判断clusterrole授权是否存在
ifClusterrole

# 判断证书文件是否存在
for f in ${SSL_FILES[@]};
do
    echo "Check if ssl file $f exist..."
    ifExist $f
    echo "OK"
done

echo "Create CSR file..."
createCSR
echo "$CSR created"
echo "Create user's certificates and keys..."


cd $USER_SSL_PATH
cfssl gencert -ca=${SSL_PATH}/ca.pem -ca-key=${SSL_PATH}/ca-key.pem -config=${SSL_PATH}/ca-config.json -profile=kubernetes $CSR| cfssljson -bare $USER_SA

# 创建 sa
$kubectl_17 create sa ${USER} -n default

# 设置集群参数
$kubectl_17 config set-cluster kubernetes \
--certificate-authority=${SSL_PATH}/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=${USER}.kubeconfig

# 设置客户端认证参数
$kubectl_17 config set-credentials ${USER_SA} \
--client-certificate=${USER_SSL_PATH}/${USER_SA}.pem \
--client-key=${USER_SSL_PATH}/${USER_SA}-key.pem \
--embed-certs=true \
--kubeconfig=${USER}.kubeconfig

# 设置上下文参数
$kubectl_17 config set-context kubernetes \
--cluster=kubernetes \
--user=${USER_SA} \
--namespace=default \
--kubeconfig=${USER}.kubeconfig

# 设置默认上下文
$kubectl_17 config use-context kubernetes --kubeconfig=${USER}.kubeconfig

# 创建 namespace
# $kubectl_17 create ns $USER

# 绑定角色
# $kubectl_17 create rolebinding ${USER}-admin-binding --clusterrole=admin --user=$USER --namespace=$USER --serviceaccount=$USER:default
$kubectl_17 create clusterrolebinding ${USER}-binding --clusterrole=${Authorization} --user=${USER_SA}

# $kubectl_17 config get-contexts

#eg
#sh create-user-kubeconfig.sh https://10.127.0.16:6443 admin cluster-admin


kubectl describe secrets -n default `kubectl  get secrets -n default | grep admin-token | awk '{print $1}'` | grep 'token:' > admin-token
sed -i "1s/^/    /"   admin-token
sed -i "s/token:      /token: /g"
cat admin-token >>  $USER_SSL_PATH/${USER}.kubeconfig


echo "Congratulations!"
echo "Your kubeconfig file is $USER_SSL_PATH/${USER}.kubeconfig"

cp $USER_SSL_PATH/${USER}.kubeconfig  ~/.kube/config

kubectl config view
