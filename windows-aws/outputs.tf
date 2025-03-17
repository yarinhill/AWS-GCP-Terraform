output "AWS_REGION" {
  description = "AWS_REGION: "
  value       = var.region
}

output "Windows_IP" {
  description = "The IP of the Windows Instance"
  value = "${aws_instance.windows.public_ip}"
}

output "Windows_Username" {
  description = "Windows Username"
  value = "Administrator"
}

output "Command_To_Decrypt_Password" {
  description =  "Decrypt the Password from AWS Cli with the following command"
  value       =  "aws ec2 get-password-data --instance-id ${aws_instance.windows.id} --priv-launch-key ~/.ssh/id_rsa_${var.project_name}.pem"     
}

output "RDP_File" {
  description = "RDP File Location"
  value       =  "${path.module}/windows-instance.rdp"
}