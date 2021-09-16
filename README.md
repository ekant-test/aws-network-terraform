# Templates

A Terraform module for building a base network in AWS.

The network consists of:

Public and private subnets for each supplied availability zone
A NAT gateway for each supplied availability zone for outbound Internet connectivity
Routes from the public subnets to the Internet gateway
Routes from the private subnets to the NAT
Standard tags for all resources

![Diagram of infrastructure managed by this module]()


### Inputs

| Name                             | Description                                                                               | Default | Required                                     |
|----------------------------------|-------------------------------------------------------------------------------------------|:-------:|:--------------------------------------------:|
| vpc_cidr                         | The CIDR to use for the VPC                                                               | -       | yes                                          |
| region                           | The region into which to deploy the VPC                                                   | -       | yes                                          |
| Account ID                       | The Account ID of the Account                                                             | -       | yes                                          |



### Outputs

| Name                         | Description                                          |
|------------------------------|------------------------------------------------------|
| vpc_id                       | The ID of the created VPC                            |
| vpc_cidr                     | The CIDR of the created VPC                          |
| subnet_ids                   | The IDs of the public subnets                        |                |
| nat_public_ips               | The EIPs attached to the NAT gateways                |
