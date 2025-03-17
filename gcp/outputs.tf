output "bastion_public_ip" {
  description = "Bastion Public IP"
  value       = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}

output "connect_to_bastion" {
  description = "SSH Command to connect to Bastion Instance"
  value       = "ssh -i ${var.private_key_file} ${var.remote_user}@${google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip}"
}
