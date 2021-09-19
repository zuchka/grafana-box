#!/bin/bash

# create new 'terraform.tfvars' file with injected vars
# don't hard-code values here
function makeTfvars () {
  cat <<EOT > ./"${GFB_FOLDER}"/terraform.tfvars
gce_ssh_pub_key_file = "${GRAFANA_BOX_SSH}"
image_family         = "${IMAGE_FAMILY}"
image_project        = "${DISTRO}"
build                = "${WORKFLOW}" 
machine_type         = "${MACHINE_TYPE}"
cpu_count            = "${CPU_COUNT}"
name                 = "${GFB_FOLDER}"
EOT
}

function makeTfvarsTest () {
  cat <<EOT > ./"${GFB_FOLDER}"/terraform.tfvars
gce_ssh_pub_key_file = "${GRAFANA_BOX_SSH}"
name                 = "${GFB_FOLDER}"
EOT
}
