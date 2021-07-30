```
yum install epel-release -y
yum install ansible –y



cat /etc/ansible/hosts
[web]
10.10.3.30   #ssh-copy-id  root@10.10.3.30
[db]
10.10.3.29 ansible_ssh_user=root ansible_ssh_pass="p@ss0rd"


ansible db -m ping
ansible web -m command -a 'chdir=/opt/ ls'
ansible web -m shell -a 'ps -ef |grep mysql'
ansible web -m copy -a 'src=test.sh  dest=/data/'
ansible web -m copy -a 'src=test.sh  dest=/data/test.sh mode=666'
ansible web -m shell -a 'ls -l /data/'
ansible web -m cron -a 'name="ntp update every 5 min" minute=*/5 job="/sbin/ntpdate 172.17.0.1 &> /dev/null"'
ansible web -m yum -a 'name=unzip state=present'
ansible web -m yum -a 'name=unzip state=absent'
ansible web -m script -a 'test.sh'
ansible web -m setup -a 'filter="*mem*"'


https://www.cnblogs.com/keerya/p/7987886.html
https://www.cnblogs.com/keerya/p/8004566.html
```
