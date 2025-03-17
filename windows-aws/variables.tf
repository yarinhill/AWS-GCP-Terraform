variable "profile" {
  type    = string
  default = "default"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "windows-instance"
}

variable "vpc_cidr" {
  type        = string
  default     = "192.168.0.0/16"  
}

variable "public_subnets" {
  type        = list(string)
  default     = ["192.168.0.0/20"]
}

variable "your_public_ip" {
  type    = list(string)
  default = ["1.1.1.1/32"]
}

#Windows-Type
variable "windows_instance_type" { // x86
  type    = string
  default = "t3.small"
}

#x86_64 AMI-Type
variable ami_type {
  type    = string
  default = "Windows_Server-2025-English-Full-Base-2025.01.15"
}

data "aws_ami" "windowsAmi" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base*"]
  }
}