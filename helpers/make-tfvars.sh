#!/bin/bash

function makeTfvars () {
  # create new 'terraform.tfvars' file with injected vars
  cat <<EOT > ./gcp/terraform.tfvars
gce_ssh_pub_key_file = "${GRAFANA_BOX_SSH}"
credentials_file     = "${GRAFANA_BOX_CRED}"
image_family         = "${IMAGE_FAMILY}"
image_project        = "${DISTRO}"
build                = "${WORKFLOW}" 
# branch               = "${BRANCH}"
machine_type         = "${MACHINE_TYPE}"
cpu_count            = "${CPU_COUNT}"
EOT
}
