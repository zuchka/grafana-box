#!/bin/bash

# initial flow control before dropping into getopts
# either destroy boxes or copy template for new box
if [[ "${1}" =~ ^destroy$ ]]; then
  GFB_FOLDERS=$(find . -type f -iname "terraform.tfvars" | sed s/terraform\.tfvars//g)
  while IFS= read -r line; do
    terraform -chdir="$line"/ destroy -auto-approve
  done <<< "${GFB_FOLDERS}"
  exit
else 
  GFB_FOLDER=$(date +%s)
  cp -r ./templates/gcp ./"${GFB_FOLDER}"
fi

# add ./grafana-box.sh delete to remove folders with warning
