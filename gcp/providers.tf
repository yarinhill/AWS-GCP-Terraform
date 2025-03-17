provider "google" {
  credentials = file("iam.json")
  project = var.gcp_project_id
  region  = var.region
}

provider "google-beta" {
  credentials = file("iam.json")
  project     = var.gcp_project_id
  region      = var.region
}

terraform {
  required_version = ">= 1.3.0"
}

data "google_compute_zones" "available" {
  region = var.region
}

data "template_file" "start_bastion_script" {
  template = file("${path.module}/user_data/start-bastion.sh")
  vars = {
    remote_user      = var.remote_user
    region           = var.region
    project_name     = var.project_name
    private_key_file = var.private_key_file
  }
}

resource "random_integer" "subnet_index" {
  min = 0
  max = length(module.vpc.subnets) - 1  
}

resource "random_shuffle" "zones" {
  input        = data.google_compute_zones.available.names
  result_count = 1
}
