# Watchdog Configuration

The file `node.softdog.config` ensures the softdog kernel module is loaded so that Pacemaker can use a watchdog for node fencing.
Ansible copies it to `/etc/modules-load.d/softdog.conf` and immediately loads the module with `modprobe`.

```bash
softdog
```

## Explanation of Key Settings

- **softdog** – The module name placed in `/etc/modules-load.d/softdog.conf` so the kernel loads it during boot.

## About Softdog

Softdog is a software watchdog driver built into the Linux kernel. It exposes `/dev/watchdog` and resets an internal timer every time a process writes to that device. If the timer is not fed before it expires, softdog logs the failure and forces a system reboot. This provides watchdog functionality even on systems without dedicated hardware.

Key characteristics:

- Pure software implementation using a kernel timer.
- Timeout is controlled by the `soft_margin` module parameter (default around 60 seconds).
- Uses the standard Linux watchdog API, so tools like the `watchdog` daemon or SBD can interact with it.
- When the timeout triggers, the module calls the kernel reboot routine to restart the node.

## Role in the Cluster

Pacemaker uses the SBD daemon for fencing. SBD relies on `/dev/watchdog` to guarantee that a node can self-reset if it stops responding. Loading the `softdog` module provides this watchdog interface even in a virtualized environment where no hardware watchdog exists. If SBD fails to "feed" the watchdog because the node hangs or loses I/O, softdog will reboot the machine, preventing it from causing split-brain in the cluster.

## Technologies and Packages

- **softdog kernel module** – Implements a software watchdog via `/dev/watchdog`.
- **SBD** – Uses the watchdog device to ensure nodes can fence themselves when unresponsive.
- **systemd-modules-load** – Loads the `softdog` module at boot from `/etc/modules-load.d/softdog.conf`.
