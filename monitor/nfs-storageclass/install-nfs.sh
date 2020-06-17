systemctl stop firewalld.service
yum -y install nfs-utils rpcbind nfs-common
mkdir -p /data/nfs_data
chmod 755 /data/nfs_data

cat > /etc/chrony.conf <<EOF
/data/nfs_data  *(rw,sync,no_root_squash)
EOF

systemctl enable rpcbind.service
systemctl enable nfs.service
systemctl start rpcbind.service
systemctl start nfs.service

