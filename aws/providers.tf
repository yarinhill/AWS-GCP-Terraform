provider "aws" {
  profile = var.profile
  region  = var.region
  alias   = "region-master"
}

terraform {
  required_version = ">= 1.11.0"
}

data "aws_availability_zones" "available" {
  state = "available"
}

#Bastion Start Script
data "template_file" "start_bastion_script" {
  template = file("${path.module}/user_data/start-bastion.sh")
  vars = {
    remote_user          = var.remote_user,
    region-master        = var.region,
    deploy-name          = var.project_name,
    private_key_file     = var.private_key_file,
  }
}
#Create key-pair for logging into EC2 for Instance
resource "aws_key_pair" "master-key" {
  provider   = aws.region-master
  key_name   = var.project_name
  public_key = file(var.public_key_file)
}

#Random Public Subnet Index 
resource "random_integer" "subnet_index" {
  min = 0
  max = length(module.vpc.public_subnets) - 1
}
