#!/bin/bash

###################################################
#                                                 #
#                COMMAND EXAMPLES                 #
#  pattern:                                       #
#  . grafana-box.sh <OS> <WORKFLOW> <ARCH>        #
#                                                 #
#  build developer environment:                   #
#  . grafana-box.sh centos-8 devenv intel         #
#                                                 #
#  build from specific binary on AMD EPYC:        #
#  . grafana-box.sh windows-2016 8.1.1 amd        #
#                                                 #
#  build from native package manager:             #
#  . grafana-box.sh debian-9 package intel        #
#                                                 #
###################################################


usage() { echo -e "Usage: $0 [-d <distro>] [-w <workflow>] [-p <processor>]\n" 1>&2; exit 1; }

while getopts ":d:w:p:" o; do
    case "${o}" in
        d)
            d=${OPTARG}            
            if ! [[ "$d" =~ $(echo ^\($(paste -sd'|' distro-list)\)$) ]]; then
              echo -e "You have not chosen a valid distro.\nPlease choose one from the following list:\n"
              cat distro-list
              echo -e "\n"              
              usage
            else
              DISTRO=${d}
            fi
            
            # more variable assignment based on distro
            if [[ ${DISTRO} =~ ubuntu ]]; then
              IMAGE_FAMILY=ubuntu-os-cloud
            elif [[ ${DISTRO} =~ debian ]]; then
              IMAGE_FAMILY=debian-cloud
            elif [[ ${DISTRO} =~ centos ]]; then
              IMAGE_FAMILY=centos-cloud
            elif [[ ${DISTRO} =~ windows ]]; then
              IMAGE_FAMILY=windows-cloud
            # else
            #   echo "You have not chosen a valid os. Please choose your parameters from the following list:"
            #   cat distro-list
            #   # usage
            fi
            ;;
        w)
            w=${OPTARG}
            if ! [[ "$w" =~ ^(devenv|package|[0-9]\.[0-9]\.[0-9]+)$ ]]; then
              echo -e "You have not chosen a valid workflow.\nPlease choose one from the following list:\n\n* package (if available, uses native package manager)\n* devenv  (fresh build from main branch. Grafana Frontend (yarn start) and Backend (make run) launched in detached Tmux sessions)\n* version (enter as 3 digits. -w 7.5.10, for example, will install Grafana version 7.5.10)\n"              
              usage
            else
              WORKFLOW=${w}
            fi
            
            if [[ ${WORKFLOW} =~ ^devenv$ ]]; then
              CPU_COUNT=8
            else
              CPU_COUNT=2
            fi
            ;;
        p)
            p=${OPTARG}
            if [[ "$p" =~ ^amd$ ]]; then
              MACHINE_TYPE=n2d
            else
              MACHINE_TYPE=e2
            fi
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${d}" ] || [ -z "${w}" ]; then
  usage
fi

echo -e "all fields validated\nbuilding Terraform plan..."
echo machine_type is ${MACHINE_TYPE}
echo cpu_count is ${CPU_COUNT}
echo image_family is ${IMAGE_FAMILY}
echo image_project is ${DISTRO}
echo workflow is ${WORKFLOW}

# create new 'terraform.tfvars' file with injected vars
cat <<EOT > gcp/terraform.tfvars
gce_ssh_pub_key_file = "${GRAFANA_BOX_SSH}"
credentials_file     = "${GRAFANA_BOX_CRED}"
image_family         = "${IMAGE_FAMILY}"
image_project        = "${DISTRO}"
build                = "${WORKFLOW}" 
# branch               = "${BRANCH}"
machine_type         = "${MACHINE_TYPE}"
cpu_count            = "${CPU_COUNT}"
EOT

# create new binary setup script with injected vars
cat <<EOT > gcp/scripts/binary.sh
#!/bin/bash

# make sure we are home
cd /home/grafana

# packages
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y adduser libfontconfig1 wget

# get binary (not the standalone)
wget https://dl.grafana.com/oss/release/grafana_${GRAFANA_BOX_VERSION}_amd64.deb
sudo dpkg -i grafana_${GRAFANA_BOX_VERSION}_amd64.deb

# start and add to systemd
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT

# kick off terraform build
# cd gcp/
# terraform apply
