# Systemd Defaults

The file `node.systemd.config` overrides selected settings in `/etc/systemd/system.conf`. Ansible copies it to that location so that systemd uses higher task limits suitable for running the cluster services.

```ini
# Lines copied from node.systemd.config
[Manager]
#DefaultTasksAccounting=yes
#DefaultTasksMax=512
DefaultTasksMax=4096
```

## Explanation of Key Settings

- **[Manager]** – Section header for system-wide manager configuration in `system.conf`.
- **DefaultTasksMax=4096** – Raises the maximum number of tasks (processes or threads) any service unit can create. The default in SUSE is 512; 4096 allows Pacemaker, Corosync, and related services to spawn more helpers without hitting the limit.

## Technologies and Packages

- **systemd** – The init system and service manager on modern Linux distributions. Settings in `/etc/systemd/system.conf` adjust global behavior.
- **Pacemaker/Corosync** – High‑availability components that benefit from an increased task limit during cluster failover scenarios.

