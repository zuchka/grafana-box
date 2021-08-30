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


usage() { echo "Usage: $0 [-d <string>] [-w <string>] [-p <string>]" 1>&2; exit 1; }

while getopts ":d:w:p:" o; do
    case "${o}" in
        d)
            d=${OPTARG}            
            if ! [[ "$d" =~ $(echo ^\($(paste -sd'|' distro-list)\)$) ]]; then
              usage
            fi
            ;;
        w)
            w=${OPTARG}
            ;;
        p)
            p=${OPTARG}
            ((p == "intel" || p == "amd")) || usage
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

DISTRO=${d}
PROCESSOR=${p}
WORKFLOW=${w}
# BRANCH=
echo "distro = ${d}"
echo "processor = ${p}"
echo "workflow = ${w}"

# validate user input

if [[ ${DISTRO} =~ ^(ubuntu-1604-lts|ubuntu-1804-lts|ubuntu-2004-lts)$ ]]; then
  IMAGE_FAMILY=ubuntu-os-cloud
elif [[ ${DISTRO} =~ ^(debian-9|debian-10|debian-11)$ ]]; then
  IMAGE_FAMILY=debian-cloud
elif [[ ${DISTRO} =~ ^(centos-7|centos-8|centos-stream-8)$ ]]; then
  IMAGE_FAMILY=centos-cloud
elif [[ ${DISTRO} =~ ^(windows-2016|windows-2019)$ ]]; then
  IMAGE_FAMILY=windows-cloud
else
  echo "You have not chosen a valid os. Please choose your parameters from the following list:"
  cat gcloud-boxes
  exit
fi

# add standalone binary support. currently binaries installed from deb file
if [[ ${WORKFLOW} =~ ^[0-9]\.[0-9]\.[0-9]+$ ]]; then
  BUILD=binary
  CPU_COUNT=2
  GRAFANA_BOX_VERSION=${WORKFLOW}
elif [[ ${WORKFLOW} =~ ^devenv$ ]]; then
  BUILD=devenv
  CPU_COUNT=8
elif [[ ${WORKFLOW} =~ ^package$ ]]; then
  BUILD=package
  CPU_COUNT=2
else
  echo "You have not chosen a valid workflow. Please choose your parameters from the following list:"
  echo -e "\ndevenv\npackage\n[GRAFANA_VERSION_AS_3_DIGITS] e.g. enter 8.1.2 for Grafana Version 8.1.2"
  exit
fi

if [[ ${PROCESSOR} =~ ^amd$ ]]; then
  MACHINE_TYPE=n2d
elif [[ ${PROCESSOR} =~ ^intel$ ]]; then
  MACHINE_TYPE=e2
else
  echo -e "Please choose intel or amd for the processor type. example:\n. grafana-box.sh centos-8 8.1.1 amd"
  exit
fi

echo -e "all fields validated\nbuilding Terraform plan..."


# create new 'terraform.tfvars' file with injected vars
cat <<EOT > gcp/terraform.tfvars
gce_ssh_pub_key_file = "${GRAFANA_BOX_SSH}"
credentials_file     = "${GRAFANA_BOX_CRED}"
image_family         = "${IMAGE_FAMILY}"
image_project        = "${DISTRO}"
build                = "${BUILD}" 
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
cd gcp/
terraform apply
