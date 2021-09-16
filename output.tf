output "accounts" {
  description = "a map of accounts and their respective managed networks"
  value = {
    #  workloads
    (module.workloads_account.account_id) = {
      vpcs = module.workloads_account.vpcs
      tgw  = module.workloads_account.transit_gateway
    }
  }
}
