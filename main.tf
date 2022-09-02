module "network" {
  source     = "./modules/network"
}

module "compute" {
  depends_on = [module.network]
  source     = "./modules/compute"
}
