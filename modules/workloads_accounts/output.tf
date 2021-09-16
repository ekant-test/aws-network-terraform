output "account_id" {
  description = "the account id in which the resources were created"
  value       = local.account_id
}

output "transit_gateway" {
  description = "the transit gateway id"
  value       = aws_ec2_transit_gateway.default_tgw.id
}

output "vpcs" {
  description = "the VPC configuration in this acccount"
  value = {
    default = {
      id         = aws_vpc.default.id
      name       = "default"
      cidr_block = aws_vpc.default.cidr_block
      subnet_ids = {
        "fw_subnets"        = values(aws_subnet.fw_subnets)[*].id
        "protected_subnets" = values(aws_subnet.protected_subnets)[*].id
        "eks_subnets"       = values(aws_subnet.eks_subnets)[*].id
        "workloads_subnets" = values(aws_subnet.workloads_subnets)[*].id
        "tgw_subnets"       = values(aws_subnet.tgw_subnets)[*].id
      }
      subnets = {
        "fw_subnets" = [
          for key, value in aws_subnet.fw_subnets : {
            id                = value.id
            arn               = value.arn
            name              = local.fw_subnets[key].name
            vpc_id            = value.vpc_id
            owner_id          = value.owner_id
            availability_zone = value.availability_zone
            cidr_block        = value.cidr_block
          }
        ]
        "protected_subnets" = [
          for key, value in aws_subnet.protected_subnets : {
            id                = value.id
            arn               = value.arn
            name              = local.protected_subnets[key].name
            vpc_id            = value.vpc_id
            owner_id          = value.owner_id
            availability_zone = value.availability_zone
            cidr_block        = value.cidr_block
          }
        ]
        "eks_subnets" = [
          for key, value in aws_subnet.eks_subnets : {
            id                = value.id
            arn               = value.arn
            name              = local.eks_subnets[key].name
            vpc_id            = value.vpc_id
            owner_id          = value.owner_id
            availability_zone = value.availability_zone
            cidr_block        = value.cidr_block
          }
        ]
        "workloads_subnets" = [
          for key, value in aws_subnet.workloads_subnets : {
            id                = value.id
            arn               = value.arn
            name              = local.workloads_subnets[key].name
            vpc_id            = value.vpc_id
            owner_id          = value.owner_id
            availability_zone = value.availability_zone
            cidr_block        = value.cidr_block
          }
        ]
      }
    }
  }
}
