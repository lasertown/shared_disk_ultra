#!/bin/bash

crm configure primitive dlm ocf:pacemaker:controld op monitor interval="60" timeout="60"
crm configure primitive gfs2-1 ocf:heartbeat:Filesystem params device="/dev/disk/by-label/hacluster\:mygfs2" directory="/mnt/shared" fstype="gfs2" op monitor interval="20" timeout="40" op start timeout="60" op stop timeout="60" meta target-role="Stopped"

crm configure group g-storage dlm  gfs2-1
crm configure clone cl-storage g-storage meta interleave="true

