variable "project" {
  default = "grafana-box"
}

variable "region" {
  default = "us-west1"
}

variable "zone" {
  default = "us-west1"
}

variable "gce_ssh_user" {
  default = "grafana"
}

variable "credentials_file" {}

variable "gce_ssh_pub_key_file" {}

variable "image_project" {}

variable image_family {}

variable workflow {}

variable code_version {}