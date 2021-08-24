terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.80.0"
    }
  }
}
provider "google" {
  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}
resource "google_compute_address" "ip_address" {
  name = "my-address"
}
data "google_compute_image" "ubuntu_image" {
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}
resource "google_compute_firewall" "default" {
  name    = "grafana-port"
  network = "default"

  # allow {
  #   protocol = "icmp"
  # }

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }
}

# resource "google_compute_network" "default" {
#   name = "default"
# }
resource "google_compute_instance" "instance_with_ip" {
  name         = "grafana-box"
  machine_type = "e2-standard-4"
  zone         = "us-west1-c"

  provisioner "remote-exec" {
    script = "./scripts/setup-binary.sh"

    connection {
      type     = "ssh"
      user     = "grafana"
      # password = "${var.root_password}"
      host     = self.network_interface[0].access_config[0].nat_ip
  }
}

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_image.self_link
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.ip_address.address
    }
  }

  metadata = {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
}

# print ip address to console here?
