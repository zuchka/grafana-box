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
            
            # more variable assignment based on distro
            if [[ ${DISTRO} =~ ubuntu ]]; then
              IMAGE_FAMILY=ubuntu-os-cloud
            elif [[ ${DISTRO} =~ debian ]]; then
              IMAGE_FAMILY=debian-cloud
            elif [[ ${DISTRO} =~ centos ]]; then
              IMAGE_FAMILY=centos-cloud
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
wget https://dl.grafana.com/oss/release/grafana_${GF_VERSION}_amd64.deb
sudo dpkg -i grafana_${GF_VERSION}_amd64.deb

# start and add to systemd
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT

# kick off terraform build
cd gcp/
terraform apply
