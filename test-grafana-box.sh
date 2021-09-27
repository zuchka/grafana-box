#!/bin/bash

# shellcheck disable=SC1090
START_TIME="$(date +%s)"

# run init script to copy template & set directory variables 
# OR destroy boxes on "destroy"
. test-init.sh

# source helper functions AFTER init script
for helper in helpers/*.sh; do
  . "${helper}"
done

makeTfvarsTest
testDebPackage
testRpmPackage
# testPackageHash

# kick off terraform build
terraform -chdir="${GFB_FOLDER}"/ init
terraform -chdir="${GFB_FOLDER}"/ apply -auto-approve
# terraform -chdir=${GFB_FOLDER}/ show

# testPackage
exportMetrics "${START_TIME}"

if [[ "${1}" =~ ^checksum$ ]]; then
terraform -chdir="${GFB_FOLDER}"/ destroy -auto-approve
fi
