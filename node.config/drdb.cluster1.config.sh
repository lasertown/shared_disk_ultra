sudo crm configure rsc_defaults resource-stickiness="200"

# Enable maintenance mode
sudo crm configure property maintenance-mode=true

sudo crm configure primitive drbd_NW1_nfs \
  ocf:linbit:drbd \
  params drbd_resource="NW1-nfs" \
  op monitor interval="15" role="Master" \
  op monitor interval="30" role="Slave"

sudo crm configure ms ms-drbd_NW1_nfs drbd_NW1_nfs \
  meta master-max="1" master-node-max="1" clone-max="2" \
  clone-node-max="1" notify="true" interleave="true"

sudo crm configure primitive fs_NW1_sapmnt \
  ocf:heartbeat:Filesystem \
  params device=/dev/drbd0 \
  directory=/srv/nfs/NW1  \
  fstype=xfs \
  op monitor interval="10s"

sudo crm configure primitive nfsserver systemd:nfs-server \
  op monitor interval="30s"
sudo crm configure clone cl-nfsserver nfsserver

sudo crm configure primitive exportfs_NW1 \
  ocf:heartbeat:exportfs \
  params directory="/srv/nfs/NW1" \
  options="rw,no_root_squash,crossmnt" clientspec="*" fsid=1 wait_for_leasetime_on_stop=true op monitor interval="30s"

sudo crm configure primitive vip_NW1_nfs \
  IPaddr2 \
  params ip=10.0.0.4 cidr_netmask=24 op monitor interval=10 timeout=20

sudo crm configure primitive nc_NW1_nfs azure-lb port=61000

sudo crm configure group g-NW1_nfs \
  fs_NW1_sapmnt exportfs_NW1 nc_NW1_nfs vip_NW1_nfs

sudo crm configure order o-NW1_drbd_before_nfs inf: \
  ms-drbd_NW1_nfs:promote g-NW1_nfs:start

sudo crm configure colocation col-NW1_nfs_on_drbd inf: \
  g-NW1_nfs ms-drbd_NW1_nfs:Master

sudo touch /etc/delete.to.retry.drdb.cluster1.config.sh
