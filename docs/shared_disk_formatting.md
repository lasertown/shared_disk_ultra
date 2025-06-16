# Shared Disk Formatting

The script `node.shared.config.py` scans for the 64 GB shared disk attached to each node, partitions it, and formats it with GFS2. Pacemaker later mounts this filesystem so that all nodes can access the same data.

```python
#!/usr/bin/python

import subprocess

lsblk = subprocess.Popen(['lsblk'], stdout=subprocess.PIPE,)
grep = subprocess.Popen(['grep', '-w', '64G'], stdin=lsblk.stdout, stdout=subprocess.PIPE,)
disk = grep.stdout.readlines()
id = []
for i in disk:
  subprocess.call(['sudo', 'parted', '-s', '/dev/' + i.split()[0], 'mklabel', 'gpt'])
  subprocess.call(['sudo', 'parted', '-s', '-a', 'opt', '/dev/' + i.split()[0], 'mkpart', 'extended', '0%', '100%'])
  subprocess.call(['sudo', 'mkfs.gfs2', '-O', '-t', 'hacluster:mygfs2', '-p', 'lock_dlm', '-j', '2', '/dev/' + i.split()[0] + '1'])
g = open("/etc/delete.to.retry.node.shared.config.py", "w")
g.close()
```

## Explanation of Key Sections

- **Disk discovery** – `lsblk | grep -w 64G` locates the 64 GB shared disk that all nodes can access.
- **Partitioning** – Runs `parted` to create a GPT label and a single partition covering the entire disk.
- **Filesystem creation** – Calls `mkfs.gfs2` with the `lock_dlm` protocol, cluster name `hacluster`, and two journals so the filesystem can be mounted by multiple nodes simultaneously.
- **Cleanup marker** – Touches `/etc/delete.to.retry.node.shared.config.py` to signal that formatting completed successfully.

## Technologies and Packages

- **parted** – Command-line partitioning tool that writes a GPT label and partition.
- **gfs2-utils** – Provides `mkfs.gfs2` for creating the shared GFS2 filesystem.
- **lock_dlm** – Distributed Lock Manager used by GFS2 for concurrent access.
- **Python** – Executes the shell commands via the `subprocess` module.
