# Corosync Configuration

Below is the Corosync configuration file copied to `/etc/corosync/corosync.conf` by Ansible. It defines how cluster nodes communicate and log events.

```ini
# Please read the corosync.conf.5 manual page

totem {
    version:    2
    secauth:    on
    crypto_hash:    sha1
    crypto_cipher:  aes256
    cluster_name:   hacluster
    clear_node_high_bit: yes

    token:      30000
    token_retransmits_before_loss_const: 10
    join:       60
    consensus:  36000
    max_messages:   20

    interface {
        ringnumber: 0

        mcastport:   5405
        ttl: 1
    }

    transport: udpu
}

logging {
    fileline:   off
    to_stderr:  no
    to_logfile:     no
    logfile:    /var/log/cluster/corosync.log
    to_syslog:  yes
    debug:      off
    timestamp:  on
    logger_subsys {
        subsys:     QUORUM
        debug:  off
    }
}

nodelist {
    node {
        ring0_addr: 10.0.0.6

        nodeid: 1
    }
}

quorum {
    # Enable and configure quorum subsystem (default: off)
    # see also corosync.conf.5 and votequorum.5
    provider: corosync_votequorum
    expected_votes: 1
    two_node: 0
}
```

## Explanation of Key Sections

- **totem block** – Defines parameters for the TOTEM protocol, Corosync’s messaging engine.
  - `secauth: on` with `crypto_hash: sha1` and `crypto_cipher: aes256` enables encrypted and authenticated traffic.
  - `token`, `token_retransmits_before_loss_const`, `join`, `consensus`, and `max_messages` tune timing and retry limits for membership.
  - `transport: udpu` uses unicast UDP instead of multicast.
  - The nested `interface` block sets ring number 0, UDP port `5405`, and a TTL of 1 (local network only).
- **logging block** – Controls Corosync log output.
  - Logs to `/var/log/cluster/corosync.log` and syslog, with timestamps enabled.
- **nodelist block** – Lists cluster nodes. Initially contains one node at `10.0.0.6` with ID `1`.
- **quorum block** – Uses the `corosync_votequorum` plugin with `expected_votes: 1`.
  - `two_node: 0` means quorum follows normal rules rather than two-node mode.

## Technologies and Packages

- **Corosync** – Provides the reliable group messaging used by Pacemaker.
- **Pacemaker** – Cluster resource manager relying on Corosync for membership information.
- **UDPU transport** – Unicast UDP mode for environments without multicast.
- **Votequorum** – Corosync plugin that handles quorum calculation for the cluster.
