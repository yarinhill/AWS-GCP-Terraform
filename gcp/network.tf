locals {
  public_subnets = [
    for subnet in var.public_subnets : merge(subnet, {
      region        = var.region,
      subnet_ip     = subnet.cidr,       # Assuming the CIDR is being used as subnet_ip
      subnet_name   = subnet.name,       # Using the name provided for subnet_name
      subnet_region = var.region         # Using the region passed as input
    })
  ]
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 10"
  project_id   = var.gcp_project_id
  network_name = "${var.project_name}-vpc"
  routing_mode = "GLOBAL"
  subnets = local.public_subnets
  routes = [
    {
      name              = "${var.project_name}-internet-route"
      description       = "Route for public subnet internet access"
      destination_range = "0.0.0.0/0"
      tags              = "public"
      next_hop_internet = true
    }
  ]
}
