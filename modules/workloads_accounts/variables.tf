variable "common_tags" {
  type        = map(string)
  description = "the common tags to apply to the managed resources"
}


# variable "accounts" {
#   type = map(object({
#     id          = string
#     name        = string
#     description = string
#     arn         = string
#     email       = string
#     production  = bool
#   }))
#   description = "account information from landing zone required to setup the network"
# }

variable "default_vpc_cidr" {
  description = "CIDR block of the npr VPC"
}

# variable "cloud_id" {
#   description = "the id of the DNS VPC hosting the shared Route53 resolver"
# }
