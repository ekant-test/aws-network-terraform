# -- VA Modules Network --------------------------------------------------------

module "workloads_account" {
  source           = "./modules/workloads_accounts"
  common_tags      = local.common_tags
  default_vpc_cidr = var.default_vpc_cidr
  providers = {
    aws = aws.wl_account
  }
}
