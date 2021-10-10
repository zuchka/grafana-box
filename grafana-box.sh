#!/bin/bash

# shellcheck disable=SC1090

# run init script to copy template & set directory variables 
# OR destroy boxes on "destroy"
. init.sh

# source helper functions AFTER init script
for helper in helpers/*.sh; do
  . "${helper}"
done

# validate args
while getopts ":d:w: :a :n: :z: :r: :e" o; do
  validateArgs "${o}"
done

shift "$((OPTIND-1))"

# check for valid branch and nulls
validateBranch
nullCheck

# generate provisioning scripts and terraform.tfvars
makeBinary
makePackage
makeDevenv
makeE2eBinary
makeTfvars

# kick off terraform build
terraform -chdir="${GFB_FOLDER}"/ init
terraform -chdir="${GFB_FOLDER}"/ apply -auto-approve
# terraform -chdir=${GFB_FOLDER}/ show

# print the VM ip + metadata
printValues
