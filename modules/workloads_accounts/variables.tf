variable "common_tags" {
  type        = map(string)
  description = "the common tags to apply to the managed resources"
}

variable "default_vpc_cidr" {
  description = "CIDR block of the npr VPC"
}
