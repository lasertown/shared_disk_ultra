# Skip initial synchronization
sudo drbdadm new-current-uuid --clear-bitmap NW1-nfs
sudo drbdadm new-current-uuid --clear-bitmap NW2-nfs

# Set the primary node
sudo drbdadm primary --force NW1-nfs
sudo drbdadm primary --force NW2-nfs

# Create file systems on the drbd devices
sudo mkfs.xfs -K /dev/drbd0
sudo mkdir /srv/nfs/NW1
sudo chattr +i /srv/nfs/NW1
sudo mount -t xfs /dev/drbd0 /srv/nfs/NW1
sudo mkdir /srv/nfs/NW1/sidsys
sudo mkdir /srv/nfs/NW1/sapmntsid
sudo mkdir /srv/nfs/NW1/trans
sudo mkdir /srv/nfs/NW1/ASCS
sudo mkdir /srv/nfs/NW1/ASCSERS
sudo mkdir /srv/nfs/NW1/SCS
sudo mkdir /srv/nfs/NW1/SCSERS
sudo umount /srv/nfs/NW1

sudo mkfs.xfs -K /dev/drbd1
sudo mkdir /srv/nfs/NW2
sudo chattr +i /srv/nfs/NW2
sudo mount -t xfs /dev/drbd1 /srv/nfs/NW2
sudo mkdir /srv/nfs/NW2/sidsys
sudo mkdir /srv/nfs/NW2/sapmntsid
sudo mkdir /srv/nfs/NW2/trans
sudo mkdir /srv/nfs/NW2/ASCS
sudo mkdir /srv/nfs/NW2/ASCSERS
sudo mkdir /srv/nfs/NW2/SCS
sudo mkdir /srv/nfs/NW2/SCSERS
sudo umount /srv/nfs/NW2

touch /etc/delete.to.retry.drdb.create
