#!/bin/bash
set -e

# 创建存储etcd数据目录
mkdir -p /data/etcd

# 下载二进制etcd包，并把执行文件放到 /k8s/kubernetes/bin/ 目录
cd /data/etcd/
wget https://github.com/etcd-io/etcd/releases/download/v3.4.7/etcd-v3.4.7-linux-amd64.tar.gz
tar zxvf etcd-v3.4.7-linux-amd64.tar.gz
cd etcd-v3.4.7-linux-amd64
cp -a etcd etcdctl /k8s/etcd/bin/

