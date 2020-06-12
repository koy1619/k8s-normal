#!/bin/bash
set -e


APP_NAME="paas-app"
log_addr="172.16.0.12:60005"
docker_registry="registry-vpc.cn-shanghai.aliyuncs.com/app"


git clone git@github.com:paas/$APP_NAME
cd  ./$APP_NAME
sed -i "s/server-addr: paas-nacos-config:8848/server-addr: nacos-0.nacos-headless.default.svc.ebuy-k8s.local:8848,nacos-1.nacos-headless.default.svc.ebuy-k8s.local:8848,nacos-2.nacos-headless.default.svc.ebuy-k8s.local:8848/g" core/src/main/resources/application.yml
sed -i "s/level value=\"debug\"/level value=\"info\"/g" core/src/main/resources/logback-spring.xml
mvn install



############################################
cat << EOF | tee filebeat-$APP_NAME.yml 
filebeat.prospectors:
- input_type: log
  paths:
   - /app/logs/$APP_NAME.log
  document_type: $APP_NAME
  tail_files: true
  backoff_factor: 1
  close_inactive: 1h
  fields_under_root: true
output.logstash:
  hosts: ["$log_addr"]
EOF



cat << EOF | tee start.sh
JAVA_OPTS="-Xms128m -Xmx512m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m"
JAVA_OPTS="\$JAVA_OPTS -Dspring.profiles.active=pro"
filebeat -e -c /app/filebeat-$APP_NAME.yml &
java -jar \$JAVA_OPTS /app/$APP_NAME-core.jar
tail -f /app/logs/$APP_NAME.log
EOF


rm -rf Dockerfile
cat << EOF | tee Dockerfile
FROM $docker_registry/jdk
ENV TZ "Asia/Shanghai"
ENV LANG C.UTF-8
VOLUME /tmp

WORKDIR /app
ADD ./core/target/$APP_NAME-core.jar .
ADD ./filebeat-$APP_NAME.yml .
ADD ./start.sh .

WORKDIR /app

ENTRYPOINT sh start.sh
EOF
############################################

#打包上传docker私服
VERSION=v$(date +%Y%m%d%H%M%S)
docker build -t $APP_NAME .
docker tag $APP_NAME $docker_registry/$APP_NAME:$VERSION
docker push $docker_registry/$APP_NAME:$VERSION

##部署(┬＿┬)s

kubectl create -f ${APP_NAME}.yaml  --record
sleep 10
kubectl get pods |grep ${APP_NAME}

##滚动更新(┬＿┬)s

#kubectl set image deployment nginx-demo-server nginx-demo-server=system386/nginx-ingress-demo:0.3 --record
#kubectl set image deployment nginx-demo-server nginx-demo-server=system386/nginx-ingress-demo:0.2 --record
#kubectl set image deployment nginx-demo-server nginx-demo-server=system386/nginx-ingress-demo:0.1 --record
#kubectl rollout history deployment nginx-demo-server
#watch -n 1 -d  'kubectl describe deployments.apps  nginx-demo-server'
