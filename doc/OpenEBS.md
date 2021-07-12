```bash
wget https://raw.githubusercontent.com/openebs/openebs/master/k8s/openebs-operator.yaml         # update OPENEBS_IO_LOCALPV_HOSTPATH_DIR
wget https://raw.githubusercontent.com/openebs/openebs/master/k8s/openebs-storageclasses.yaml
kubectl apply -f openebs-operator.yaml
kubectl apply -f openebs-storageclasses.yaml

wget https://raw.githubusercontent.com/openebs/openebs/master/k8s/demo/jenkins/jenkins.yml
kubectl apply -f jenkins.yml

$ kubectl get pv
$ kubectl get pvc
```



https://www.bookstack.cn/read/kubernetes-handbook/practice-using-openebs-for-persistent-storage.md
