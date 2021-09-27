terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.80.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

locals {
  dist = {
    ubuntu-1804-lts = "ubuntu-os-cloud"
    ubuntu-2004-lts = "ubuntu-os-cloud"
    debian-10       = "debian-cloud"
    debian-11       = "debian-cloud"
    centos-7        = "centos-cloud"
    centos-8        = "centos-cloud"
    # centos-stream-8 = "centos-cloud"
    rocky-linux-8 = "rocky-linux-cloud"
  }
}


resource "google_compute_address" "ip_address" {
  name     = "ip-${var.name}-${each.key}"
  for_each = local.dist
}

resource "google_compute_firewall" "default" {
  name     = "firewall-${var.name}-${each.key}"
  network  = "default"
  for_each = local.dist

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }
}

resource "google_compute_instance" "instance_with_ip" {
  for_each     = local.dist
  name         = "instance-${var.name}-${each.key}"
  machine_type = "${var.machine_type}-standard-${var.cpu_count}"


  provisioner "remote-exec" {
    script = "./scripts/${each.value}-test.sh"

    connection {
      type = "ssh"
      user = "grafana"
      host = self.network_interface[0].access_config[0].nat_ip
    }
  }

  boot_disk {
    initialize_params {
      image = "${each.value}/${each.key}"
      size  = 25
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.ip_address[each.key].address
    }
  }

  metadata = {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
}

# print ip address to console here?
output "instance_ip" {
  value = google_compute_address.ip_address[*]
}