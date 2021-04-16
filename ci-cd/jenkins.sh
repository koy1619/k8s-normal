#!/bin/bash
export JAVA_HOME=/usr/local/jdk1.8.0_111
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$JAVA_HOME/bin:$PATH
export NODE_OPTIONS="--max-old-space-size=4096"
JENKINS_ROOT=/app/jenkins
export JENKINS_HOME=$JENKINS_ROOT/jenkins_home
cd $JENKINS_ROOT

PIDS=`ps -ef|grep -w "jenkins.war"|grep -v grep|awk '{print $2}'`
echo "stop jenkins....."
kill -9 $PIDS && sleep 5

echo "start jenkins....."
nohup  java \
 -Dhudson.util.ProcessTree.disable=true \
 -Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true \
 -Xms2048m -Xmx2048m \
 -XX:PermSize=1024M \
 -XX:PermSize=1024M \
 -jar $JENKINS_ROOT/jenkins.war \
 --httpPort=8000 \
 > jenkins.log 2>&1 &


####Plugins####
#Role-based Authorization Strategy
#Git plugin
#Subversion Plug-in
#Multiple SCMs plugin
#Publish Over SSH
#SonarQube Scanner for Jenkins
#ThinBackup
#Pipeline
#Git Parameter
#Localization: Chinese (Simplified)
