# Requires the latest Terraform and Ansible
Azure Cloudshell has both Terraform and Ansible preinstalled, so cloning and launching from Cloudshell is convienent.
# Clone the repository and run this command from root of project folder:
$ ansible-playbook -i myazure_rm.yml lab.yml
The cluster will be created in a resource group specified in the root module's main.tf.
# Deleting the cluster
The cluster can be deprovisioned by running:
$ terraform delete
You can also simply delete the resource group the cluster is in.  
If you manually delete the resource group, terraform will leave behind the files:
terraform.tfstate
terraform.tfstate.backup
Delete the tfstate files and you ready to spin up another cluster.  If you do not want to wait for the previous resource group to be deleted, you can create a new resource group name in main.tf