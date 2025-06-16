# lab.yml Breakdown

The `lab.yml` playbook orchestrates creation and configuration of a two-node Pacemaker cluster in Azure. Each play below is shown with its corresponding Ansible code and a short explanation.

## Create lab environment
```yaml
- name: Create lab environment
  hosts: localhost
  connection: local
  tasks:
  - name: Generate personal SSH keys if they do not already exist
    openssh_keypair:
      path: ~/.ssh/id_rsa
      force: False
      regenerate: never
  - name: Generate Lab SSH keys
    openssh_keypair:
      path: ~/.ssh/lab_rsa
      force: False
      regenerate: never      
  - name: Terraform apply
    terraform:
      lock: no
      force_init: true
      project_path: './'
      state: present
  - name: Configure local alias
    blockinfile:
      path: ~/.bashrc
      state: present
      block: |
        alias bastion='ssh -i ~/.ssh/lab_rsa azureadmin@`terraform output -raw bastion_ip`'
        ANSIBLE_STDOUT_CALLBACK=debug
  - name: Terraform refresh
    shell: terraform refresh
  - name: Create rg file for dynamic inventory
    shell: echo { \"rg\":\"`terraform output -raw rg`\" } > rg.json
  - name: Include vars of stuff.yaml into the 'stuff' variable
    include_vars:
      file: rg.json
      name: stuff
  - name: Configure dynamic inventory file
    blockinfile:
      path: ./myazure_rm.yml
      state: present
      block: |
        include_vm_resource_groups:
        - {{ stuff["rg"] }}
  - name: Refresh inventory to ensure new instances exist in inventory
    meta: refresh_inventory
```
This play creates the infrastructure using Terraform, generates SSH keys, and refreshes the dynamic inventory so subsequent plays can target the new VMs.

## Zypper update
```yaml
- name: Zypper update
  hosts: all
  remote_user: azureadmin
  become: yes
  tasks:
  - name: Zypper update
    command: sudo zypper up -y --skip-interactive
```
Updates all SUSE packages on every host to ensure the latest versions are installed.

## Push SSH key to bastion
```yaml
- name: Push SSH key to bastion
  hosts: tag_group_bastion
  remote_user: azureadmin
  become: yes
  tasks:
  - name: Set personal authorized key taken from file
    authorized_key:
      user: azureadmin
      state: present
      key: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"
  - name: Push SSH azureadmin private key
    copy:
      src: ~/.ssh/lab_rsa
      dest: /home/azureadmin/.ssh/id_rsa
      mode: '0600'
      owner: azureadmin
      group: users
  - name: Configure etc hosts
    blockinfile:
      path: /etc/hosts
      state: present
      block: |
        # Cluster nodes
        10.0.0.6 node-0
        10.0.0.7 node-1
```
Copies personal SSH keys and hosts entries to the bastion VM so it can act as a jump host for the cluster nodes.

## Push SSH config
```yaml
- name: Push SSH config
  hosts: all
  remote_user: azureadmin
  tasks:
  - name: Push SSH config to all VMs
    copy:
      src: ssh.config/ssh.config
      dest: /home/azureadmin/.ssh/config
      owner: azureadmin
      group: users
```
Deploys a shared SSH configuration file to simplify connecting to all hosts.

## Push root SSH keys to nodes
```yaml
- name: Push root SSH keys to nodes
  hosts: tag_group_node0 tag_group_node1
  remote_user: azureadmin
  become: yes
  tasks:
  - name: Create /root/.ssh directory
    file:
      path: /root/.ssh/
      state: directory
      mode: '0700'
  - name: Copy root private key
    copy:
      src: ~/.ssh/lab_rsa
      dest: /root/.ssh/id_rsa
      owner: root
      group: root
      mode: '0600'
  - name: Copy root public key to authorized keys
    copy:
      src: ~/.ssh/lab_rsa.pub
      dest: /root/.ssh/authorized_keys
      owner: root
      group: root
      mode: '0644'
  - name: Copy root public key to .ssh
    copy:
      src: ~/.ssh/lab_rsa.pub
      dest: /root/.ssh/id_rsa.pub
      owner: root
      group: root
      mode: '0644'
  - name: Configure etc hosts
    blockinfile:
      path: /etc/hosts
      state: present
      block: |
        # IP address of the first cluster node
        10.0.0.6 node-0
        # IP address of the second cluster node
        10.0.0.7 node-1

```
Distributes root SSH keys and updates /etc/hosts on each node so they can communicate without passwords.

## Configure nodes
```yaml
- name: Configure nodes
  hosts: tag_group_node0 tag_group_node1
  remote_user: azureadmin
  become: yes
  tasks:
  - name: Enable iscsid
    service:
      name: iscsid
      enabled: yes
  - name: Enable iscsi
    service:
      name: iscsi
      enabled: yes
  - name: Enable sbd
    command: sudo systemctl enable sbd
  - name: Start iscsid
    service:
      name: iscsid
      state: restarted
  - name: Start iscsi
    service:
      name: iscsi
      state: restarted
  - name: Retrieve IDs of iSCSI devices, Create the SBD devices, Adapt the SBD config
    script: node.config/node.sbd.config.py
    args:
      executable: python
      creates: /etc/delete.to.retry.node.sbd.config.py
  - name: Create the softdog configuration file
    copy:
      src: node.config/node.softdog.config
      dest: /etc/modules-load.d/softdog.conf   
  - name: Load softdog module
    command: sudo modprobe -v softdog
  - name: Install socat
    zypper:
      name: socat
      state: present
  - name: Install resource-agents
    zypper:
      name: resource-agents
      state: present
  - name: Configure systemd
    copy:
      src: node.config/node.systemd.config
      dest: /etc/systemd/system.conf
      owner: root
      group: root  
      mode: '0644'
  - name: Reload daemon-reload
    command: sudo systemctl daemon-reload 
  - name: Configure systemd
    copy:
      src: node.config/node.sysctl.config
      dest: /etc/sysctl.conf
      owner: root
      group: root  
      mode: '0644'
  - name: Configure interface
    run_once: true
    copy:
      src: node.config/node.interface.config
      dest: /etc/sysconfig/network/ifcfg-eth0
      owner: root
      group: root  
      mode: '0644'
  - name: Install fence-agents
    zypper:
      name: fence-agents
      state: present
```
Enables iSCSI and SBD services, loads the softdog watchdog, installs required packages, and copies system configuration files to both cluster nodes.

## Configure node0
```yaml
- name: Configure node0
  hosts: tag_group_node0
  remote_user: azureadmin
  become: yes
  tasks:
  - name: Stop corosync
    command: sudo service corosync stop
    args:
      creates: /etc/corosync/corosync.conf
  - name: Stop pacemaker
    command: sudo service pacemaker stop
    args:
      creates: /etc/corosync/corosync.conf
  - name: Configure ha-cluster-init
    expect:
      command: sudo ha-cluster-init -u
      echo: yes
      creates: /etc/corosync/corosync.conf
      responses:
        "Do you want to continue anyway (y/n)?": "y"
        "/root/.ssh/id_rsa already exists - overwrite (y/n)?": "n"
        '  Address for ring0': ""
        "  Port for ring0": ""
        "Do you wish to use SBD (y/n)?": "y"
        "Do you wish to configure a virtual IP address (y/n)?": "n"
        'csync2 is already configured - overwrite (y/n)?': 'y'
        '/etc/corosync/authkey already exists - overwrite (y/n)?': 'y'        
        '/etc/pacemaker/authkey already exists - overwrite (y/n)?': 'y'
        'SBD is already configured to use': 'n'
      timeout: 300
  - name: Update corosync config
    copy:
      src: node.config/node.corosync.config
      dest: /etc/corosync/corosync.conf
  - name: Restart corosync
    command: sudo service corosync restart

```
Initializes the first node using `ha-cluster-init` and replaces Corosync's configuration before restarting the service.

## Configure node1
```yaml
- name: Configure node1
  hosts: tag_group_node1
  remote_user: azureadmin
  become: yes
  tasks:
  - name: Stop corosync
    command: sudo service corosync stop
    args:
      creates: /etc/corosync/corosync.conf
  - name: Stop pacemaker
    command: sudo service pacemaker stop
    args:
      creates: /etc/corosync/corosync.conf
  - name: Join node to cluster
    expect:
      command: sudo ha-cluster-join
      echo: yes
      creates: /etc/corosync/corosync.conf
      responses:
        'Do you want to continue anyway (y/n)?': 'y'
        '  IP address or hostname of existing node': '10.0.0.6'
        '/root/.ssh/id_rsa already exists - overwrite (y/n)?': 'n'
        '  Address for ring0': ''
      timeout: 300
```
Joins the second node to the cluster with `ha-cluster-join`.

## Configure node0 STONITH
```yaml
- name: Configure node0
  hosts: tag_group_node0
  remote_user: azureadmin
  become: yes
  tasks:
  - name: Configure stonith device
    script: node.config/node.stonith.config.sh
    args:
      creates: /etc/delete.to.retry.node.stonith.config.sh
```
Runs a script that sets up the SBD fencing device on node0.

## Install GFS packages
```yaml
- name: Install GFS packages
  hosts: tag_group_node0 tag_group_node1
  remote_user: azureadmin
  become: yes
  tasks:
  - name: Install gfs2-utils
    zypper:
      name: gfs2-utils
      state: present
```
Installs the GFS2 utilities so that the shared filesystem can be created later.

## Create GFS
```yaml
- name: Create GFS
  hosts: tag_group_node0
  remote_user: azureadmin
  become: yes
  tasks:
  - name: Create GFS partition and filesystem
    script: node.config/node.shared.config.py
    args:
      executable: python
      creates: /etc/delete.to.retry.node.shared.config.py
  - name: Create GFS cluster resources
    script: node.config/node.gfs.config.sh
    args:
      creates: /etc/delete.to.retry.node.gfs.config.sh

```
Runs scripts to partition the shared disk and configure Pacemaker resources for the GFS2 filesystem.

## Sync disks
```yaml
- name: Sync disks
  hosts: tag_group_node1
  remote_user: azureadmin
  become: yes
  tasks:
  - name: Sync disks to pickup GFS changes
    command: partprobe
```
Runs `partprobe` on the second node so it detects the new partition table.

## Start GFS cluster resource
```yaml
- name: Start GFS cluster resource
  hosts: tag_group_node0
  remote_user: azureadmin
  become: yes
  tasks:
  - name: Start GFS resource 
    command: crm resource start gfs2-1
```
Starts the newly created GFS2 resource so it mounts on node0.
