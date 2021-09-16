provider "aws" {
  alias = "wl_account"
  # assume_role {
  #   role_arn = "arn:aws:iam::${var.workload_account_id}:role/${var.cross_account_execution_role}"
  # }
}

# provider "aws" {
#   alias = "wl_account_1"
#   assume_role {
#     role_arn = "arn:aws:iam::${var.workload_account_id_1}:role/${var.cross_account_execution_role}"
#   }
# }
