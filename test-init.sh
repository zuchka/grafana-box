#!/bin/bash

# initial flow control before dropping into getopts
# either destroy boxes or copy template for new box
if [[ "${1}" =~ ^destroy$ ]]; then
  GFB_FOLDERS=$(find . -type f -iname "terraform.tfvars" | sed s/terraform\.tfvars//g)
  while IFS= read -r line; do
    terraform -chdir="$line"/ destroy -auto-approve
  done <<< "${GFB_FOLDERS}"
  exit
elif [[ "${1}" =~ ^package$ ]]; then 
  # will need new logic to set $workflow dynamically
  GFB_FOLDER=$(date +%s)
  cp -r ./gcp-test ./"${GFB_FOLDER}"
else
  exit
fi

# add ./grafana-box.sh delete to remove folders with warning
