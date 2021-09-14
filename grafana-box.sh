#!/bin/bash

# run init script to copy template & set directory variables 
# OR destroy boxes on "destroy"
. ./init.sh

# source helper functions AFTER init script
for helper in ./helpers/*.sh; do
  . "${helper}"
done


# validate args
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