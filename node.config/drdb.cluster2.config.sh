# Enable maintenance mode
sudo crm configure property maintenance-mode=true

sudo crm configure primitive drbd_NW2_nfs \
  ocf:linbit:drbd \
  params drbd_resource="NW2-nfs" \
  op monitor interval="15" role="Master" \
  op monitor interval="30" role="Slave"

sudo crm configure ms ms-drbd_NW2_nfs drbd_NW2_nfs \
  meta master-max="1" master-node-max="1" clone-max="2" \
  clone-node-max="1" notify="true" interleave="true"

sudo crm configure primitive fs_NW2_sapmnt \
  ocf:heartbeat:Filesystem \
  params device=/dev/drbd1 \
  directory=/srv/nfs/NW2  \
  fstype=xfs \
  op monitor interval="10s"

sudo crm configure primitive exportfs_NW2 \
  ocf:heartbeat:exportfs \
  params directory="/srv/nfs/NW2" \
  options="rw,no_root_squash,crossmnt" clientspec="*" fsid=2 wait_for_leasetime_on_stop=true op monitor interval="30s"

sudo crm configure primitive vip_NW2_nfs \
  IPaddr2 \
  params ip=10.0.0.5 cidr_netmask=24 op monitor interval=10 timeout=20

sudo crm configure primitive nc_NW2_nfs azure-lb port=61001

sudo crm configure group g-NW2_nfs \
  fs_NW2_sapmnt exportfs_NW2 nc_NW2_nfs vip_NW2_nfs

sudo crm configure order o-NW2_drbd_before_nfs inf: \
  ms-drbd_NW2_nfs:promote g-NW2_nfs:start

sudo crm configure colocation col-NW2_nfs_on_drbd inf: \
  g-NW2_nfs ms-drbd_NW2_nfs:Master

sudo touch /etc/delete.to.retry.drdb.cluster2.config.sh
