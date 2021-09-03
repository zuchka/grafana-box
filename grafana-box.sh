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

# validate args
usage() { echo -e "Usage: $0 [-d <distro>] [-w <workflow>] [optional: -a <FLAG_ONLY> runs AMD processors instead of default Intel]\n" 1>&2; exit 1; }

while getopts ":d:w: :a" o; do
    case "${o}" in
        d)
            d=${OPTARG}
            #pattern-match the argument against a list in a file           
            if ! [[ "$d" =~ $(echo ^\($(paste -sd'|' distro-list)\)$) ]]; then
              echo -e "You have not chosen a valid distro.\nPlease choose one from the following list:\n"
              cat distro-list
              echo -e "\n"              
              usage
            else
              DISTRO=${d}
            fi
            
            if [[ ${DISTRO} =~ ubuntu ]]; then
              IMAGE_FAMILY=ubuntu-os-cloud
            elif [[ ${DISTRO} =~ debian ]]; then
              IMAGE_FAMILY=debian-cloud
            elif [[ ${DISTRO} =~ centos ]]; then
              IMAGE_FAMILY=centos-cloud
            elif [[ ${DISTRO} =~ rocky ]]; then
              IMAGE_FAMILY=rocky-linux-cloud
            elif [[ ${DISTRO} =~ windows ]]; then
              IMAGE_FAMILY=windows-cloud          
            fi
            ;;
        w)
            w=${OPTARG}
            if ! [[ "$w" =~ ^(devenv|package|[0-9]\.[0-9]\.[0-9]+)$ ]]; then
              echo -e "You have not chosen a valid workflow.\nPlease choose one from the following list:\n\n* package (if available, uses native package manager)\n* devenv  (fresh build from main branch. Grafana Frontend (yarn start) and Backend (make run) launched in detached Tmux sessions)\n* version (enter as 3 digits. -w 7.5.10, for example, will install Grafana version 7.5.10)\n"              
              usage
            elif [[ "$w" =~ ^[0-9]\.[0-9]\.[0-9]+$ ]]; then
              WORKFLOW=binary
              GF_VERSION=${w}
              CPU_COUNT=2
            elif [[ ${w} =~ ^devenv$ ]]; then
              WORKFLOW=${w}
              CPU_COUNT=8
            else
              WORKFLOW=${w}
              CPU_COUNT=2
            fi
            ;;
        a)
            MACHINE_TYPE=n2d
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# these two parameters can't be null
if [ -z "${d}" ] || [ -z "${w}" ]; then
  usage
fi

# workaround to keep the -a flag optional but set a default when it's absent
if ! [[ ${MACHINE_TYPE} == n2d ]]; then
  MACHINE_TYPE=e2
fi

echo -e "\nall fields validated\n"
echo -e "machine_type ====> ${MACHINE_TYPE}"
echo "cpu_count =======> ${CPU_COUNT}"
echo "image_family ====> ${IMAGE_FAMILY}"
echo "image_project ===> ${DISTRO}"
echo -e "workflow ========> ${WORKFLOW}\n"
echo -e "building Terraform plan...\n"

# generate provisioning scripts and terraform.tfvars
makeTfvars
makeBinary
makePackage
makeDevenv

# kick off terraform build
terraform -chdir=gcp/ apply
terraform -chdir=gcp/ show