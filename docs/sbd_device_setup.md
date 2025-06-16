# SBD Device Setup

The script `node.sbd.config.py` automates creation of SBD (STONITH Block Device) disks and updates `/etc/sysconfig/sbd` so Pacemaker can use them for fencing.

```python
    #!/usr/bin/python
    
    import subprocess
    
    lsblk = subprocess.Popen(['lsblk'], stdout=subprocess.PIPE,)
    grep = subprocess.Popen(['grep', '-w', '4G'], stdin=lsblk.stdout, stdout=subprocess.PIPE,)
    disk = grep.stdout.readlines()
    id = []
    for i in disk:
      ls = subprocess.Popen(['ls', '-la', '/dev/disk/by-id/'], stdout=subprocess.PIPE,)
      grep2 = subprocess.Popen(['grep', i[0:3]], stdin=ls.stdout, stdout=subprocess.PIPE,)
      grep3 = subprocess.Popen(['grep', 'scsi-3'], stdin=grep2.stdout, stdout=subprocess.PIPE,)
      id.append('/dev/disk/by-id/' + grep3.stdout.read().split()[8])
    for i in id:
      subprocess.call(['sudo', 'sbd', '-d', i, '-1', '60', '-4', '120', 'create'])
    e = open("/tmp/sbd", "a")
    f = open("/etc/sysconfig/sbd", "r")
    for i in (f.read().splitlines()):
      if "#SBD_DEVICE=" in i:
        e.write("SBD_DEVICE=" + "\"" + ";".join(id) + "\"" + "\n")
      else:
        e.write(i + "\n")
    e.close()
    f.close()
    subprocess.call(['cp', '/tmp/sbd', '/etc/sysconfig/sbd'])
    subprocess.call(['rm', '/tmp/sbd'])
    g = open("/etc/delete.to.retry.node.sbd.config.py", "w")
    g.close()
```

## Explanation of Key Sections

- **Disk discovery** – Runs `lsblk | grep -w 4G` to locate the 4 GB disks dedicated to SBD. The script collects their `/dev/disk/by-id/` paths that include the `scsi-3` identifier.
- **Create SBD metadata** – For each disk found, calls `sbd create` with timeouts (`-1 60 -4 120`) to initialize the device.
- **Update configuration** – Reads `/etc/sysconfig/sbd`, replaces the commented `SBD_DEVICE` line with the list of disk paths separated by semicolons, and writes it to a temporary file before copying it back.
- **Cleanup marker** – Touches `/etc/delete.to.retry.node.sbd.config.py` after completion so Ansible can detect success.

## Technologies and Packages

- **sbd** – The STONITH Block Device agent providing I/O fencing for Pacemaker.
- **Pacemaker** – Uses the SBD devices for fencing when `stonith` is enabled.
- **Python** – Executes shell commands via `subprocess` for disk discovery and configuration file editing.
