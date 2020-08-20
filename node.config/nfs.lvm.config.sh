parted -s /dev/disk/azure/scsi1/lun0 mklabel gpt mkpart primary 0% 100%
parted -s /dev/disk/azure/scsi1/lun1 mklabel gpt mkpart primary 0% 100%
sleep 3
sudo pvcreate /dev/disk/azure/scsi1/lun0-part1  
sudo vgcreate vg-NW1-NFS /dev/disk/azure/scsi1/lun0-part1
sudo lvcreate -l 100%FREE -n NW1 vg-NW1-NFS
sudo pvcreate /dev/disk/azure/scsi1/lun1-part1
sudo vgcreate vg-NW2-NFS /dev/disk/azure/scsi1/lun1-part1
sudo lvcreate -l 100%FREE -n NW2 vg-NW2-NFS
sudo touch /etc/delete.to.retry.nfs.lvm.config.sh