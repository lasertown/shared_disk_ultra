# STONITH (Fencing) Setup

The script `node.stonith.config.sh` configures Pacemaker to use the SBD fencing agent. It sets cluster properties and defines the STONITH primitive.

```bash
sudo crm configure property stonith-timeout=144
sudo crm configure property stonith-enabled=true
sudo crm configure primitive stonith-sbd stonith:external/sbd \
   params pcmk_delay_max="15" \
   op monitor interval="15" timeout="15"
sudo touch /etc/delete.to.retry.nfs.stonith.config.sh
```

## Explanation of Key Lines

- `stonith-timeout=144` – Maximum time Pacemaker waits for a fencing action to complete.
- `stonith-enabled=true` – Enables fencing within the cluster.
- `primitive stonith-sbd` – Creates a STONITH resource using the external SBD agent.
  - `pcmk_delay_max="15"` adds a random delay (up to 15 seconds) to prevent simultaneous fences.
  - `op monitor interval="15" timeout="15"` tells Pacemaker to monitor the agent every 15 seconds.
- The script touches `/etc/delete.to.retry.nfs.stonith.config.sh` so Ansible can detect that the script has run successfully.

## Technologies and Packages

- **Pacemaker** – Cluster resource manager issuing the STONITH commands via `crm`.
- **SBD** – External fencing agent that uses the previously initialized SBD devices.
- **CRM Shell** – Pacemaker command-line interface used to configure cluster properties and resources.
