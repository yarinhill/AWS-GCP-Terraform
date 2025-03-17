resource "google_compute_instance" "bastion" {
  name         = "${var.project_name}-bastion"
  machine_type = var.machine_type
  zone         = random_shuffle.zones.result[0]
  scheduling {
    preemptible       = true  # Enables preemptible VM
    provisioning_model = "SPOT"  # Uses the new Spot VM model
    automatic_restart = false  # Required for Spot VMs
  }
  boot_disk {
    initialize_params {
      image = var.machine_image
      size  = 10
      type  = "pd-balanced"
    }
  }
  connection {
    type        = "ssh"
    user        = var.remote_user
    private_key = file("${var.private_key_file}")
    host        = self.network_interface[0].access_config[0].nat_ip  # Corrected attribute to access public IP
  }
  provisioner "file" {
    source      = var.private_key_file
    destination = "/home/${var.remote_user}/.ssh/id_rsa"
  }
  network_interface {
    network    = module.vpc.network_name  # Reference network from the vpc module
    subnetwork = values(module.vpc.subnets)[random_integer.subnet_index.result].name  # Get subnet dynamically by index
    access_config {}  # Ensures public IP
  }
  metadata_startup_script = data.template_file.start_bastion_script.rendered
  tags = ["bastion"]
  service_account {
    email  = google_service_account.bastion.email
    scopes = ["cloud-platform"]
  }
  metadata = {
    ssh-keys = "${var.remote_user}:${file(var.public_key_file)}"
  }
}

resource "google_compute_firewall" "bastion-sg" {
  name    = "${var.project_name}-bastion-sg"
  network = module.vpc.network_self_link
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = var.your_public_ip
}

resource "google_service_account" "bastion" {
  account_id   = "${var.gcp_project_id}"
  display_name = "Bastion Service Account"
}

resource "google_project_iam_binding" "bastion_roles" {
  project = var.gcp_project_id
  role    = "roles/compute.viewer"
  members = [
    "serviceAccount:${google_service_account.bastion.email}"
  ]
}
