```
wget https://get.helm.sh/helm-v2.15.2-linux-amd64.tar.gz
tar zxvf helm-v2.15.2-linux-amd64.tar.gz
cd linux-amd64/
cp -rf helm tiller /usr/bin/
cp -rf helm tiller /usr/local/bin/


cat << EOF | tee helm-rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF


kubectl apply -f helm-rbac.yaml



yum install socat -y



helm init --service-account tiller --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.15.2  --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts

kubectl get pod -n kube-system -l app=helm

helm version

