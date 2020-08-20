sudo drbdadm create-md NW1-nfs
sudo drbdadm create-md NW2-nfs
sudo drbdadm up NW1-nfs
sudo drbdadm up NW2-nfs
sudo touch /etc/delete.to.retry.drdb.create.config.sh