#!/bin/bash

###################################################
#                                                 #
#                COMMAND EXAMPLES                 #
#  minimum required pattern:                      #
#  . grafana-box.sh <OS> <WORKFLOW>               #
#                                                 #
#  build developer environment:                   #
#  . grafana-box.sh centos-8 devenv               #
#                                                 #
#  build from specific binary on AMD EPYC:        #
#  . grafana-box.sh windows-2016 8.1.1 -a         #
#                                                 #
#  build from native package manager:             #
#  . grafana-box.sh debian-9 package              #
#                                                 #
###################################################

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
nullCheck

# generate provisioning scripts and terraform.tfvars
makeBinary
makePackage
makeDevenv
makeTfvars

# kick off terraform build
terraform -chdir=gcp/ apply
terraform -chdir=gcp/ show