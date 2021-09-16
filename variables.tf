variable "default_vpc_cidr" {
  description = "CIDR block to assign to the Inspection VPC"
}

# -- landing zone account execution --------------------------------------------

variable "cross_account_execution_role" {
  type        = string
  description = "the name of the cross account execution role used to configure accounts within the orgainsational structure."
  default     = "sample-role"
}
