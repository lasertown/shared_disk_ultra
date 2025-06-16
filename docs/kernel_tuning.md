# Kernel Tuning

The file `node.sysctl.config` contains custom sysctl settings that Ansible copies to `/etc/sysctl.conf` on each node. These settings adjust how the kernel handles dirty pages to keep I/O responsive for the cluster.

```conf
####
#
# /etc/sysctl.conf is meant for local sysctl settings
#
# sysctl reads settings from the following locations:
#   /boot/sysctl.conf-<kernelversion>
#   /lib/sysctl.d/*.conf
#   /usr/lib/sysctl.d/*.conf
#   /usr/local/lib/sysctl.d/*.conf
#   /etc/sysctl.d/*.conf
#   /run/sysctl.d/*.conf
#   /etc/sysctl.conf
#
# To disable or override a distribution provided file just place a
# file with the same name in /etc/sysctl.d/
#
# See sysctl.conf(5), sysctl.d(5) and sysctl(8) for more information
#
####

# Change/set the following settings
vm.dirty_bytes = 629145600
vm.dirty_background_bytes = 314572800
```

## Explanation of Key Settings

- **vm.dirty_bytes** – Specifies the maximum amount of data (here 600 MB) that can be waiting to be written to disk before processes start writing directly.
- **vm.dirty_background_bytes** – Threshold (300 MB) at which the kernel starts writing dirty data to disk in the background.
- These values keep the page cache from growing too large, which helps maintain consistent latency for the cluster's shared storage.

## Technologies and Packages

- **sysctl** – Standard Linux mechanism for adjusting kernel parameters at runtime and via `/etc/sysctl.conf`.
- **Pacemaker/Corosync** – Benefit from tuned writeback settings to avoid delays when the cluster writes to shared storage.
