variable "gcp_project_id" {
  type    = string
  default = "your_gcp_project_id"
}

variable "project_name" {
  type    = string
  default = "quick-instance"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "vpc_cidr" {
  type        = string
  default     = "192.168.0.0/16"  
}

variable "public_subnets" {
  type = list(object({
    name = string
    cidr = string
  }))
  default = [
    { name = "public-subnet-1", cidr = "192.168.0.0/20" },
    { name = "public-subnet-2", cidr = "192.168.16.0/20" },
    { name = "public-subnet-3", cidr = "192.168.32.0/20" }
  ]
  description = "Public subnets in the VPC."
}

variable "your_public_ip" {
  type    = list(string)
  default = ["1.1.1.1/32"]
}

variable "remote_user" {
  type    = string
  default = "debian"
}

variable "public_key_file" {
  type    = string
  default = "~/.ssh/id_rsa_ter.pub"
}

variable "private_key_file" {
  type    = string
  default = "~/.ssh/id_rsa_ter"
}

/*
## For ARM Uncomment
variable "machine_type" {
  type = string
  default = "t2a-small-1"
}

variable "machine_image" {
  type = string
  default = "debian-cloud/debian-11"
}
*/

## For ARM Comment
variable "machine_type" {
  type = string
  default = "e2-small"
}

variable "machine_image" {
  type = string
  default = "debian-cloud/debian-11"
}

