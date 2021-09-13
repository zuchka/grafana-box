#!/bin/bash

# copy template into new folder for box
GFB_FOLDER=$(date +%s)
cp -r ./gcp ./${GFB_FOLDER}

# source helper functions
for helper in ./helpers/*.sh; do
  . "${helper}"
done

# validate args
if [[ "${1}" =~ ^destroy$ ]]; then
  terraform -chdir=${GFB_FOLDER}/ destroy
  exit
fi

while getopts ":d:w: :a :n:" o; do
  validateArgs
done

shift "$((OPTIND-1))"

# check for valid branch and nulls
validateBranch
nullCheck

# and then change destroy logic to search recursively through dir and find all plans

# generate provisioning scripts and terraform.tfvars
printValues
makeBinary
makePackage
makeDevenv
makeTfvars

# kick off terraform build
terraform -chdir=${GFB_FOLDER}/ init
terraform -chdir=${GFB_FOLDER}/ apply
# terraform -chdir=${GFB_FOLDER}/ show

# print the VM ip + metadata
MACHINE_IP=$(terraform -chdir=${GFB_FOLDER}/ output -raw instance_ip)
printValues