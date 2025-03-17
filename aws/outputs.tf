
output "Bastion_Public_IP" {
  description = "Bastion Public IP: "
  value       = aws_instance.bastion.public_ip
}

output "Command-to-Connect-to-the-Bastion-Instance" {
  description = "Run the following command to SSH into the Bastion Instance: "
  value       = "ssh -i ${var.private_key_file} ${var.remote_user}@${aws_instance.bastion.public_ip}"
}

output "AWS_REGION" {
  description = "AWS_REGION: "
  value       = var.region
}
