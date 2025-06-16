# GFS2 Resource Configuration

This section describes the script `node.gfs.config.sh` that Ansible executes on the cluster nodes. The script creates the Pacemaker resources needed for a shared GFS2 filesystem.

```bash
#!/bin/bash

crm configure primitive dlm ocf:pacemaker:controld op monitor interval="60" timeout="60"
crm configure primitive gfs2-1 ocf:heartbeat:Filesystem params device="/dev/disk/by-label/hacluster:mygfs2" directory="/mnt/shared" fstype="gfs2" op monitor interval="20" timeout="40" op start timeout="60" op stop timeout="60" meta target-role="Stopped"

crm configure group g-storage dlm gfs2-1
crm configure clone cl-storage g-storage meta interleave="true"
```

## Explanation of Key Sections

- **DLM primitive** – `crm configure primitive dlm ocf:pacemaker:controld` defines the Distributed Lock Manager used by GFS2. The monitor operation checks health every 60 seconds.
- **GFS2 filesystem primitive** – `crm configure primitive gfs2-1 ocf:heartbeat:Filesystem ...` creates a Filesystem resource pointing to `/dev/disk/by-label/hacluster:mygfs2` and mounting it at `/mnt/shared`. Monitoring occurs every 20 seconds. The resource starts stopped so it can be brought online when the cluster is fully configured.
- **Resource group** – `crm configure group g-storage dlm gfs2-1` groups the DLM and filesystem resources, ensuring they start together on a node.
- **Clone resource** – `crm configure clone cl-storage g-storage meta interleave="true"` clones the group across all nodes so every node mounts the GFS2 filesystem.

## Technologies and Packages

- **Pacemaker CRM shell** (`crm`) – Command interface to configure cluster resources.
- **DLM** – Distributed Lock Manager providing locking for the GFS2 filesystem.
- **GFS2** – Global File System 2, a shared-disk cluster filesystem.
- **Resource Agents** – `ocf:pacemaker:controld` and `ocf:heartbeat:Filesystem` provided by the `resource-agents` package.
