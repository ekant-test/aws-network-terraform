# configure the project specific but otherwise static values
locals {
  domain       = "example"
  service_name = "aws-network-component"
  owner        = "ekant"
  contact      = "ekantmate@gmail.com"
  costcode     = "xxxx"
  common_tags = {
    "service:name"     = local.service_name
    "service:owner"    = local.owner
    "service:contact"  = local.contact
    "billing:costcode" = local.costcode
  }
}
