provider "aws" {
  profile = var.profile
  region  = var.region
  alias   = "region-master"
}

terraform {
  required_version = ">= 1.3.0"
}

data "aws_availability_zones" "available" {
  state = "available"
}