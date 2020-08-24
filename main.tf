module "rg0" {
  source = "./modules/resource_group"
  rg = "test_cluster_ultra"
}

module "network0" {
    source = "./modules/network"
    rg = module.rg0.rg
    region = "westus2"
}

module "bastion0" {
source = "./modules/bastion"
rg = module.rg0.rg
region = module.network0.region
subnet = module.network0.subnet
publisher = "SUSE"
offer = "sles-sap-12-sp5"
sku = "gen2"
_version = "latest"
}

module "nodes0" {
source = "./modules/node_pair"
rg = module.rg0.rg
region = module.network0.region
vm_size = "Standard_D2s_v3"
az = "1"
subnet = module.network0.subnet
publisher = "SUSE"
offer = "sles-sap-12-sp5"
sku = "gen2"
_version = "latest"
}