```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  labels:
    app: redis
spec:
  selector:
    matchLabels:
      app: redis
  replicas: 1
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: redis
    spec:
      volumes:
      - name: data
        emptyDir: {}
      containers:
      - name: redis
        image: redis
        resources:
          requests:
            cpu: 250m
            memory: 512Mi
        volumeMounts:
        - mountPath: /data
          name: data
        ports:
        - containerPort: 6379
          name: redis

---

apiVersion: v1
kind: Service
metadata:
  name: redis
  labels:
    app: redis
spec:
  ports:
  - protocol: TCP
    port: 6379
    targetPort: 6379
    name: redis
  selector:
    app: redis
```

kubectl edit configmaps  tcp-services -n kube-system

```
apiVersion: v1
data:  #新增部分
  "6379": default/redis:6379    #新增部分
kind: ConfigMap
metadata:
  name: tcp-services
  namespace: kube-system
```


kubectl edit svc ingress-nginx -n kube-system

```
  ports:
  - name: http
    nodePort: 32080
    port: 80
    protocol: TCP
    targetPort: 80
  - name: https
    nodePort: 32443
    port: 443
    protocol: TCP
    targetPort: 443
  - name: redis                   #新增部分
    nodePort: 32379               #新增部分
    port: 6379                    #新增部分
    protocol: TCP                 #新增部分
    targetPort: 6379              #新增部分

```

```
[root@k8s-master ~]$kubectl  get svc -n kube-system  |grep ingress-nginx
ingress-nginx    NodePort    10.10.225.93    <none>        80:32080/TCP,443:32443/TCP,6379:32379/TCP   83d
```


```
# haproxy配置   OR   slb
listen nginx_ingress_redis
     mode tcp
     balance roundrobin
     bind 10.127.0.10:6379
     timeout client 30s
     timeout server 30s
     timeout connect 30s
     server k8s_node_1 k8s-node-1-ip:32379 weight 1 check inter 2000 rise 5 fall 10 send-proxy
     server k8s_node_2 k8s-node-2-ip:32379 weight 1 check inter 2000 rise 5 fall 10 send-proxy
```

by

https://blog.51cto.com/fengwan/2544519


其实还不如`NodePort`暴露来的简单实在
