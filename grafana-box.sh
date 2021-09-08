#!/bin/bash

# source helper functions
. ./helpers/make-tfvars.sh
. ./helpers/make-binary.sh
. ./helpers/make-package.sh
. ./helpers/make-devenv.sh
. ./helpers/validate-args.sh

# validate args
usage() { echo -e "Usage: $0 [-d <distro>] [-w <workflow>] [optional: -a <FLAG_ONLY> runs AMD processors instead of default Intel]\n" 1>&2; exit 1; }

while getopts ":d:w: :a" o; do
  validateArgs
done

# check for nulls
validateBranch
nullCheck

# generate provisioning scripts and terraform.tfvars
makeBinary
makePackage
makeDevenv
makeTfvars

# kick off terraform build
terraform -chdir=gcp/ init
terraform -chdir=gcp/ apply
terraform -chdir=gcp/ show

# TODO more graceful exit. print ip etc etc

# TODO add flag for 'terraform destroy'
# terraform -chdir=gcp/ destroy