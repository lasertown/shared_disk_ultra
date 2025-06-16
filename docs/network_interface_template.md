# Network Interface Template

The file `node.interface.config` provides a simple SUSE-style network interface configuration for the cluster nodes. Ansible copies it to `/etc/sysconfig/network/ifcfg-eth0` so the interface comes up automatically with DHCP.

```ini
BOOTPROTO='dhcp'
DHCLIENT6_MODE='managed'
MTU=''
REMOTE_IPADDR=''
STARTMODE='onboot'
CLOUD_NETCONFIG_MANAGE='yes'
```

## Explanation of Key Settings

- **BOOTPROTO='dhcp'** – Uses DHCP to obtain an IPv4 address at boot.
- **DHCLIENT6_MODE='managed'** – Enables DHCPv6 in managed mode for IPv6 configuration.
- **MTU=''** – Leaves the interface MTU at the system default.
- **REMOTE_IPADDR=''** – Placeholder for `wicked` remote IP configuration; left empty here.
- **STARTMODE='onboot'** – Brings the interface up automatically during boot.
- **CLOUD_NETCONFIG_MANAGE='yes'** – Allows cloud-init or other tools to manage the interface settings through SUSE's netconfig framework.

## Technologies and Packages

- **wicked** – SUSE's network management service that reads `/etc/sysconfig/network/ifcfg-*` files.
- **cloud-init** – May modify these settings during provisioning when `CLOUD_NETCONFIG_MANAGE` is enabled.
- **DHCP** – Used to assign IP addresses dynamically in this environment.
