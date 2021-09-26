variable "gce_ssh_pub_key_file" {}

variable "name" {}

variable "project" {
  default = "grafana-box"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "gce_ssh_user" {
  default = "grafana"
}

# variable build {
#   default = "package"
# }

variable "machine_type" {
  default = "e2"
}

variable "cpu_count" {
  default = 2
}
