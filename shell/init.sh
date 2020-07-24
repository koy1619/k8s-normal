#!/usr/bin/env bash
set -e

yum install net-tools -y
yum install yum-utils -y

function Check_linux_system(){
    linux_version=`cat /etc/redhat-release`
    if [[ ${linux_version} =~ "CentOS" ]];then
        echo -e "\033[32;32m 系统为 ${linux_version} \033[0m \n"
    else
        echo -e "\033[32;32m 系统不是CentOS,该脚本只支持CentOS环境\033[0m \n"
        exit 1
    fi
}

function Set_hostname(){
    if [ -n "$HostName" ];then
      grep $HostName /etc/hostname && echo -e "\033[32;32m 主机名已设置，退出设置主机名步骤 \033[0m \n" && return
      case $HostName in
      help)
        echo -e "\033[32;32m bash init.sh 主机名 \033[0m \n"
        exit 1
      ;;
      *)
        hostname $HostName
        echo "$HostName" > /etc/hostname
        echo "`ifconfig eth0 | grep inet | awk '{print $2}'` $HostName" >> /etc/hosts
      ;;
      esac
    else
      echo -e "\033[32;32m 输入为空，请参照 bash init.sh 主机名 \033[0m \n"
      exit 1
    fi
}

function System_config(){

    #时间同步设置
    timedatectl set-timezone Asia/Shanghai
    ntpdate ntp.aliyun.com
    timedatectl status
    yum install chrony -y
cat > /etc/chrony.conf <<EOF
server ntp.aliyun.com iburst
server ntp6.aliyun.com iburst
server cn.ntp.org.cn iburst
server ntp.shu.edu.cn iburst

driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony
EOF
    systemctl restart chronyd
    systemctl enable chronyd
    systemctl status chronyd
    chronyc sources -v
    chronyc sourcestats -v

    #设置hosts
    echo "10.127.0.16 k8s-master" >> /etc/hosts
    echo "10.127.0.17 k8s-node-1" >> /etc/hosts
    echo "10.127.0.18 k8s-node-2" >> /etc/hosts
    
    #关闭firewalld
    systemctl stop firewalld
    systemctl disable firewalld

    #清空iptables    
    iptables -F
    iptables -X
    iptables -Z
    iptables -L -n

    #关闭 swap
    swapoff -a 
    sed -i 's/.*swap.*/#&/' /etc/fstab
    
    #关闭 Selinux
    setenforce  0 
    sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux 
    sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config 
    sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/sysconfig/selinux 
    sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config 
    
    #修改内核参数
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
    sysctl -p /etc/sysctl.d/k8s.conf

    # 开启ipvs支持
    yum -y install ipvsadm  ipset
# 永久生效
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
    sysctl -p
    lsmod |grep ip_vs
    
    #kubectl命令自动补全
    yum -y install bash-completion
    
    echo 'source /usr/share/bash-completion/bash_completion'>> /etc/bashrc
    echo 'source <(kubectl completion bash)'>> /etc/bashrc
    echo "alias grep='grep --color=auto'">> /etc/bashrc
    echo "PS1='\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\$'">> /etc/bashrc
    
    #创建K8S安装目录
    mkdir /k8s/etcd/{bin,cfg} -p
    mkdir /k8s/kubernetes/{bin,cfg,ssl} -p
    
    # 预先把 /k8s/kubernetes/bin 目录加入到 PATH
    echo 'export PATH=$PATH:/k8s/kubernetes/bin' >> /etc/profile
}


function Install_depend_environment(){
    rpm -qa | grep nfs-utils &> /dev/null && echo -e "\033[32;32m 已完成依赖环境安装，退出依赖环境安装步骤 \033[0m \n" && return
    yum install -y nfs-utils curl yum-utils device-mapper-persistent-data lvm2 net-tools conntrack-tools wget vim  ntpdate libseccomp libtool-ltdl telnet
    echo -e "\033[32;32m 升级Centos7系统内核到5版本，解决Docker-ce版本兼容问题\033[0m \n"
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org && \
    rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm && \
    yum --disablerepo=\* --enablerepo=elrepo-kernel repolist && \
    yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-ml.x86_64 && \
    yum remove -y kernel-tools-libs.x86_64 kernel-tools.x86_64 && \
    yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-ml-tools.x86_64 && \
    grub2-set-default 0
    modprobe br_netfilter
    ls /proc/sys/net/bridge
}

function Install_docker(){
    rpm -qa | grep docker && echo -e "\033[32;32m 已安装docker，退出安装docker步骤 \033[0m \n" && return
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    yum makecache fast
    yum -y install docker-ce-19.03.6 docker-ce-cli-19.03.6
    # 设置 iptables file表中 FORWARD 默认链规则为 ACCEPT
    sed  -i '/ExecStart=/i ExecStartPost=\/sbin\/iptables -P FORWARD ACCEPT' /usr/lib/systemd/system/docker.service
    systemctl enable docker.service
    systemctl start docker.service
    systemctl stop docker.service
    echo '{"registry-mirrors": ["https://4xr1qpsp.mirror.aliyuncs.com"], "log-opts": {"max-size":"500m", "max-file":"3"}}' > /etc/docker/daemon.json
    systemctl daemon-reload
    systemctl start docker
    sleep 10
    journalctl -u docker -n 20 --no-pager
    systemctl status docker
}

# 初始化顺序
Check_linux_system
HostName=$1 && \
System_config && \
Set_hostname && \
Install_depend_environment && \
Install_docker


# 重启
# reboot
