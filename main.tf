module "rg0" {
  source = "./modules/resource_group"
  rg = "test_cluster"
}

module "network0" {
    source = "./modules/network"
    rg = module.rg0.rg0
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