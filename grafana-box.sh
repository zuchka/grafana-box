#!/bin/bash

###################################################
#                                                 #
#                   TEMPLATE                      #
#                                                 #
#  build developer environment from main/commit   #
#  . grafana-box.sh windows2016 devenv main       #
#                                                 #
#  build from specific binary                     #
#  . grafana-box.sh centos8 8.1.1                 #
#                                                 #
#  build from OS package manager                  #
#  . grafana-box.sh debian9 package               #
#                                                 #
###################################################

# validate user input
if [[ ${1} =~ ^(ubuntu-1604-lts|ubuntu-1804-lts|ubuntu-2004-lts)$ ]]; then
  IMAGE_FAMILY=ubuntu-os-cloud
elif [[ ${1} =~ ^(debian-9|debian-10|debian-11)$ ]]; then
  IMAGE_FAMILY=debian-cloud
elif [[ ${1} =~ ^(centos-7|centos-8|centos-stream-8)$ ]]; then
  IMAGE_FAMILY=centos-cloud
elif [[ ${1} =~ ^(windows-2016|windows-2019)$ ]]; then
  IMAGE_FAMILY=windows-cloud
else
  echo "You have not chosen a valid os. Please choose your parameters from the following list:"
  cat gcloud-boxes
  exit
fi

if [[ ${2} =~ ^[0-9]\.[0-9]\.[0-9]$ ]]; then
  WORKFLOW=binary
elif [[ ${2} =~ ^devenv$ ]]; then
  WORKFLOW=devenv
elif [[ ${2} =~ ^package$ ]]; then
  WORKFLOW=package
else
  echo "You have not chosen a valid workflow. Please choose your parameters from the following list:"
  echo -e "\ndevenv\npackage\n[GRAFANA_VERSION_AS_3_DIGITS] e.g. enter 8.1.2 for Grafana Version 8.1.2"
  exit
fi

# really needs more validating logic
if [ ${2} == "devenv" ]; then
  if ! [[ ${3} =~ ^(main|b-*|c-*) ]]; then
    echo -e "please use one of the accepted patterns for choosing a code version"
  fi
fi

# if [[ ${3} =~ ^(main|commit-pattern)$ ]]; then
#   echo -e "should we add a special logic to validate commits?"
#   exit
# fi

echo "all fields validated"

IMAGE_PROJECT=${1}
GRAFANA_BOX_VERSION=${2}
CODE_VERSION=${3}
# license=
# arch=

cat <<EOT > gcp/terraform.tfvars
gce_ssh_pub_key_file = "${GRAFANA_BOX_SSH}"
credentials_file     = "${GRAFANA_BOX_CRED}"
image_family         = "${IMAGE_FAMILY}"
image_project        = "${IMAGE_PROJECT}"
workflow             = "${WORKFLOW}" 
code_version         = "${CODE_VERSION}"
EOT

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

cd gcp/
terraform apply
