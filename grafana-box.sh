#!/bin/bash

# source helper functions
for helper in ./helpers/*.sh; do
  . "${helper}"
done

# validate args
if [[ "${1}" =~ ^destroy$ ]]; then
  terraform -chdir=gcp/ destroy
  exit
fi

while getopts ":d:w: :a :n:" o; do
  validateArgs
done

shift "$((OPTIND-1))"

# check for valid branch and nulls
validateBranch
nullCheck

# generate provisioning scripts and terraform.tfvars
printValues
makeBinary
makePackage
makeDevenv
makeTfvars

# kick off terraform build
terraform -chdir=gcp/ init
terraform -chdir=gcp/ apply
terraform -chdir=gcp/ show

# TODO more graceful exit. print ip etc etc
