variable "project" {}

variable "credentials_file" {}

variable "region" {
  default = "us-west1"
}

variable "zone" {
  default = "us-west1"
}

variable "gce_ssh_user" {}

variable "gce_ssh_pub_key_file" {}
