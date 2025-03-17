module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.15.0"
  name                 = "${var.project_name}-vpc"
  cidr                 = var.vpc_cidr
  azs                  = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets       = var.public_subnets
  private_subnets      = [] # No private subnets
  enable_nat_gateway   = false # Disable NAT gateway
  enable_dns_support   = true
  enable_dns_hostnames = true
  public_route_table_tags = {
    "Name" = "${var.project_name}-public-route-table"
  }
  igw_tags = {
    "Name" = "${var.project_name}-igw"
  }
}
