provider "aws" {
  alias = "wl_account"
}

## this block is needed if you need to call the module for another account ##
# provider "aws" {
#   alias = "wl_account_1"
#   assume_role {
#     role_arn = "arn:aws:iam::${var.workload_account_id_1}:role/${var.cross_account_execution_role}"
#   }
# }
