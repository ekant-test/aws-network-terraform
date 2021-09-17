# Terraform AWS Base Networking templates

A Terraform module for building a base network in AWS.

The main thing to consider for the template is Automated CIDR assignment with respect to availability zone

Please find below example to calculate the CIDR.

When you are using cidrsubnet("10.1.2.0/21", 3, 8), you are adding 3 bits. Since in binary 2 ^ 3 = 8, you can define maximally 8 subnets in this range: 0,1,2,..., 7 with the following cidrs:

* 10.1.0.0/24
* 10.1.1.0/24
* 10.1.2.0/24
* 10.1.3.0/24
* 10.1.4.0/24
* 10.1.5.0/24
* 10.1.6.0/24
* 10.1.7.0/24

If you want to define subnets between 0 and 15, you have to use: cidrsubnet("10.1.2.0/21", 4, 8), since 2 ^ 4 = 16 and you can have sixteen subnets: 0, 1, 2, ..., 15.

------------------------

The network consists of:

Multiple Subnets for each supplied availability zone
A NAT gateway for outbound Internet connectivity
Routes from the public subnets to the Internet gateway
Routes from the private subnets to the NAT
Standard tags for all resources




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
