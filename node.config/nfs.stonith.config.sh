sudo crm configure property stonith-timeout=144
sudo crm configure property stonith-enabled=true
sudo crm configure primitive stonith-sbd stonith:external/sbd \
   params pcmk_delay_max="15" \
   op monitor interval="15" timeout="15"
sudo touch /etc/delete.to.retry.nfs.stonith.config.sh