yum install epel-release -y
yum install conntrack-tools socat wget ipset ebtables curl vim bash-completion -y

wget https://github.com/kubesphere/kubekey/releases/download/v1.1.0/kubekey-v1.1.0-linux-amd64.tar.gz
tar xzvf kubekey-v1.1.0-linux-amd64.tar.gz
mv kk /usr/local/bin/kk
export KKZONE=cn

# all-in-one
kk create cluster --with-kubernetes v1.20.4 --with-kubesphere v3.1.0


# 使用配置文件创建集群
kk create config  --with-kubernetes v1.20.4 --with-kubesphere v3.1.0 -f /opt/config.yaml
create cluster -f /opt/config.yaml


echo 'source /usr/share/bash-completion/bash_completion'>> /etc/bashrc
echo 'source <(kubectl completion bash)'>> /etc/bashrc
echo "alias grep='grep --color=auto'">> /etc/bashrc
echo "PS1='\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\$'">> /etc/bashrc
source /etc/bashrc

