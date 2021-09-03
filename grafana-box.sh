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
            
            if [[ ${DISTRO} =~ ubuntu ]]; then
              IMAGE_FAMILY=ubuntu-os-cloud
            elif [[ ${DISTRO} =~ debian ]]; then
              IMAGE_FAMILY=debian-cloud
            elif [[ ${DISTRO} =~ centos ]]; then
              IMAGE_FAMILY=centos-cloud
            elif [[ ${DISTRO} =~ centos ]]; then
              IMAGE_FAMILY=centos-cloud
            elif [[ ${DISTRO} =~ rocky ]]; then
              IMAGE_FAMILY=rocky-linux-cloud
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

########################################################
#                                                      #
#  generate provisioning scripts and terraform.tfvars  #
#                                                      #
########################################################

makeTfvars () {
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
}

makeBinary () {
  # create new binary setup script with injected vars
  if [[ ${IMAGE_FAMILY} =~ (ubuntu|debian) ]]; then
    cat <<EOT > gcp/scripts/binary.sh
#!/bin/bash

###################################################
#                                                 #
#                  WARNING!                       #
#                                                 #
#  do not make edits to ths file (binary.sh)      #
#  a new version with updated variables           #
#  will overwrite this file every time you run    #
#  ./grafana-box.sh.                              #
#                                                 #
#        Instead, edit grafana-box.sh:lines       #
###################################################

# make sure we are home
cd /home/grafana

# packages
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y adduser libfontconfig1 wget

# get binary (not the standalone)
wget https://dl.grafana.com/oss/release/grafana_${GF_VERSION}_amd64.deb
sudo dpkg -i grafana_${GF_VERSION}_amd64.deb

# add to systemd and start
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT
elif [[ ${IMAGE_FAMILY} =~ (centos|rocky) ]]; then
  cat <<EOT > gcp/scripts/binary.sh
#!/bin/bash

###################################################
#                                                 #
#                  WARNING!                       #
#                                                 #
#  do not make edits to this file (binary.sh)     #
#  a new version with updated variables           #
#  will overwrite this file every time you run    #
#  ./grafana-box.sh.                              #
#                                                 #
#        Instead, edit grafana-box.sh:lines       #
###################################################

# make sure we are home
cd /home/grafana

# get binary (not the standalone)
sudo yum update -y
sudo yum install -y https://dl.grafana.com/oss/release/grafana-${GF_VERSION}-1.x86_64.rpm

# add to systemd and start
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT
fi
}

makePackage () {
  # create new package setup script with injected vars
  if [[ ${IMAGE_FAMILY} =~ (ubuntu|debian) ]]; then
    cat <<EOT > gcp/scripts/package.sh
#!/bin/bash

###################################################
#                                                 #
#                  WARNING!                       #
#                                                 #
#  do not make edits to this file (package.sh)    #
#  a new version with updated variables           #
#  will overwrite this file every time you run    #
#  ./grafana-box.sh.                              #
#                                                 #
#        Instead, edit grafana-box.sh:lines       #
###################################################

# packages
cd /home/grafana
sudo apt-get update  -y
sudo apt-get upgrade -y
sudo apt-get install -y software-properties-common apt-transport-https wget adduser libfontconfig1

# install grafana
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update  -y
sudo apt-get install -y grafana

# add to systemd and start
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT
elif [[ ${IMAGE_FAMILY} =~ (centos|rocky) ]]; then
  cat <<EOT > gcp/scripts/package.sh
#!/bin/bash

###################################################
#                                                 #
#                  WARNING!                       #
#                                                 #
#  do not make edits to this file (package.sh)    #
#  a new version with updated variables           #
#  will overwrite this file every time you run    #
#  ./grafana-box.sh.                              #
#                                                 #
#        Instead, edit grafana-box.sh:lines       #
###################################################

# make sure we are home
cd /home/grafana

sudo bash -c "cat > /etc/yum.repos.d/grafana.repo" <<"EOG"
#!/bin/bash

[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOG

# sudo yum update -y
sudo yum install -y grafana

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT
fi
}

# replace show with the proper command to print ip. save as var and ssh.
# ssh into server?
# you could upload instructions in a readme file in root 'using-grafana-box'

makeTfvars
makeBinary
makePackage

# kick off terraform build
terraform -chdir=gcp/ apply
terraform -chdir=gcp/ show