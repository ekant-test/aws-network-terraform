# -- create default VPC --------------------------------------------------------

resource "aws_vpc" "default" {
  enable_dns_hostnames             = true
  enable_dns_support               = true
  cidr_block                       = var.default_vpc_cidr
  assign_generated_ipv6_cidr_block = false
  instance_tenancy                 = "default"
  tags = merge(
    var.common_tags,
    map(
      "Name", "default-${local.env}",
    )
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default.id
  tags = merge(
    var.common_tags,
    map(
      "Name", "default-${local.env}",
    )
  )
}

# -- Create VPC flowlogs for VPC --#

resource "aws_flow_log" "default" {
  iam_role_arn    = aws_iam_role.default.arn
  log_destination = aws_cloudwatch_log_group.default.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.default.id
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "default-vpc-flowlogs-${local.env}"
  retention_in_days = 30
  tags = merge(
    var.common_tags,
    map(
      "Name", "default-${local.env}",
    )
  )
}

resource "aws_iam_role" "default" {
  tags = merge(
    var.common_tags,
    map(
      "Name", "default-${local.env}",
    )
  )
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "vpc-flow-logs.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "default" {
  name = "default-${local.env}"
  role = aws_iam_role.default.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

### -------------------------------------------------------------------------------------------------------------- ###

data "aws_availability_zones" "azs" {}
### -------------------------------------------------------------------------------------------------------------- ###

locals {
  azs = {
    for i in range(length(data.aws_availability_zones.azs.names)) : data.aws_availability_zones.azs.names[i] => {
      index   = i
      name    = data.aws_availability_zones.azs.names[i]
      suffix  = substr(data.aws_availability_zones.azs.names[i], length(data.aws_availability_zones.azs.names[i]) - 2, 2)
      zone_id = data.aws_availability_zones.azs.zone_ids[i]
    }
  }
}
### -------------------------------------------------------------------------------------------------------------- ###
locals {

  fw_subnets = {
    for az_name, az in local.azs : az_name => {
      availability_zone = az_name
      cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, az.index + length(local.azs) * 0)
      name              = "fw-${az.suffix}"
    }
  }

  tgw_subnets = {
    for az_name, az in local.azs : az_name => {
      availability_zone = az_name
      cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, az.index + length(local.azs) * 2)
      name              = "tgw-${az.suffix}"
    }
  }


  protected_subnets = {
    for az_name, az in local.azs : az_name => {
      availability_zone = az_name
      cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, az.index + length(local.azs) * 4)
      name              = "protected-${az.suffix}"
    }
  }

  eks_subnets = {
    for az_name, az in local.azs : az_name => {
      availability_zone = az_name
      cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, az.index + length(local.azs) * 3)
      name              = "eks-${az.suffix}"
    }
  }

  workloads_subnets = {
    for az_name, az in local.azs : az_name => {
      availability_zone = az_name
      cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, az.index + length(local.azs) * 1)
      name              = "workloads-${az.suffix}"
    }
  }
}
### -------------------------------------------------------------------------------------------------------------- ###


resource "aws_subnet" "workloads_subnets" {
  for_each          = local.workloads_subnets
  availability_zone = each.key
  vpc_id            = aws_vpc.default.id
  cidr_block        = each.value.cidr_block

  tags = merge(
    var.common_tags,
    {
      Name = each.value.name
    }
  )
}

resource "aws_subnet" "fw_subnets" {
  for_each          = local.fw_subnets
  availability_zone = each.key
  vpc_id            = aws_vpc.default.id
  cidr_block        = each.value.cidr_block
  tags = merge(
    var.common_tags,
    {
      Name = each.value.name
    }
  )
}

resource "aws_subnet" "protected_subnets" {
  for_each          = local.protected_subnets
  availability_zone = each.key
  vpc_id            = aws_vpc.default.id
  cidr_block        = each.value.cidr_block
  tags = merge(
    var.common_tags,
    {
      Name = each.value.name
    }
  )
}

resource "aws_subnet" "eks_subnets" {
  for_each          = local.eks_subnets
  availability_zone = each.key
  vpc_id            = aws_vpc.default.id
  cidr_block        = each.value.cidr_block
  tags = merge(
    var.common_tags,
    {
      Name = each.value.name
    }
  )
}

resource "aws_subnet" "tgw_subnets" {
  for_each          = local.tgw_subnets
  availability_zone = each.key
  vpc_id            = aws_vpc.default.id
  cidr_block        = each.value.cidr_block
  tags = merge(
    var.common_tags,
    {
      Name = each.value.name
    }
  )
}


# -- create route tables -------------------------------------------------------

resource "aws_route_table" "fw" {
  vpc_id = aws_vpc.default.id
  tags = merge(
    var.common_tags,
    map(
      "Name", "default-fw-${local.env}",
    )
  )
}
resource "aws_route_table_association" "fw" {
  for_each       = toset(data.aws_availability_zones.azs.names)
  subnet_id      = aws_subnet.fw_subnets[each.key].id
  route_table_id = aws_route_table.fw.id
}

resource "aws_route" "fw" {
  route_table_id         = aws_route_table.fw.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


resource "aws_route_table" "protected" {
  vpc_id = aws_vpc.default.id
  tags = merge(
    var.common_tags,
    map(
      "Name", "${local.env}_main_protected",
    )
  )
}
resource "aws_route_table_association" "protected" {
  for_each       = toset(data.aws_availability_zones.azs.names)
  subnet_id      = aws_subnet.protected_subnets[each.key].id
  route_table_id = aws_route_table.protected.id
}

resource "aws_route_table" "eks" {
  vpc_id = aws_vpc.default.id
  tags = merge(
    var.common_tags,
    map(
      "Name", "${local.env}_main_eks",
    )
  )
}
resource "aws_route_table_association" "eks" {
  for_each       = toset(data.aws_availability_zones.azs.names)
  subnet_id      = aws_subnet.eks_subnets[each.key].id
  route_table_id = aws_route_table.eks.id
}


resource "aws_route_table" "workloads" {
  vpc_id = aws_vpc.default.id
  tags = merge(
    var.common_tags,
    map(
      "Name", "${local.env}_main_workloads",
    )
  )
}
resource "aws_route_table_association" "workloads" {
  for_each       = toset(data.aws_availability_zones.azs.names)
  subnet_id      = aws_subnet.workloads_subnets[each.key].id
  route_table_id = aws_route_table.workloads.id
}

resource "aws_route_table" "tgw" {
  vpc_id = aws_vpc.default.id
  tags = merge(
    var.common_tags,
    map(
      "Name", "${local.env}_main_tgw",
    )
  )
}
resource "aws_route_table_association" "tgw" {
  for_each       = toset(data.aws_availability_zones.azs.names)
  subnet_id      = aws_subnet.tgw_subnets[each.key].id
  route_table_id = aws_route_table.tgw.id
}


resource "aws_network_acl" "default" {
  vpc_id = aws_vpc.default.id
  subnet_ids = concat(
    [for subnet in aws_subnet.fw_subnets : subnet.id],
    [for subnet in aws_subnet.protected_subnets : subnet.id],
    [for subnet in aws_subnet.eks_subnets : subnet.id],
    [for subnet in aws_subnet.workloads_subnets : subnet.id],
    [for subnet in aws_subnet.tgw_subnets : subnet.id]
  )

  ingress {
    from_port  = "0"
    to_port    = "0"
    protocol   = "-1"
    rule_no    = "100"
    action     = "Allow"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    from_port  = "0"
    to_port    = "0"
    protocol   = "-1"
    rule_no    = "100"
    action     = "Allow"
    cidr_block = "0.0.0.0/0"
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", "${local.env}_main_nacl",
    )
  )
}

# ---- EIP -----#

resource "aws_eip" "egress" {
  vpc = true
}


# ---- Nat Gateway ---#

resource "aws_nat_gateway" "egress" {
  allocation_id = aws_eip.egress.id
  subnet_id     = [for subnet in aws_subnet.fw_subnets : subnet.id][0]
  tags          = merge({ Name = "nat-gateway" }, var.common_tags)
}

# ----- Transit Gateway -----#
resource "aws_ec2_transit_gateway" "default_tgw" {
  description     = "tgw for vpc's in the network account"
  amazon_side_asn = "65522"
  tags            = merge({ Name = "tgw" }, var.common_tags)
}

resource "aws_ec2_transit_gateway_route_table" "spoke_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.default_tgw.id
  tags               = merge({ Name = "spoke_rt" }, var.common_tags)
}

resource "aws_ec2_transit_gateway_route_table" "firewall_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.default_tgw.id
  tags               = merge({ Name = "firewall_rt" }, var.common_tags)
}
