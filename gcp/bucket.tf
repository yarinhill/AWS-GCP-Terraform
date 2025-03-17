/*
terraform {
  required_version = ">= 1.3.0"
  backend "gcs" {
    bucket = "quick-instance-bucket"
    prefix = "terraform/state"
  }
}
*/