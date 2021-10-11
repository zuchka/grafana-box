#!/bin/bash

# create new package setup script with injected vars
function makePackage () {
  if [[ ${IMAGE_FAMILY} =~ (ubuntu|debian) ]]; then
    cat <<EOT > ./"${GFB_FOLDER}"/scripts/package.sh
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
#     Instead, edit ./helpers/make-package.sh     #
###################################################

# packages
cd /home/grafana || exit
sudo apt install -y apt-transport-https
sudo apt install -y libfontconfig1
sudo apt install -y software-properties-common wget

wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/${GF_LICENSE}/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

sudo apt update  -y
sudo apt install -y grafana${DEB_TAG}=7.0.0
sudo apt clean
sudo apt install -y grafana${DEB_TAG}

# add to systemd and start
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT
elif [[ ${IMAGE_FAMILY} =~ (centos|rocky) ]]; then
  cat <<EOT > ./"${GFB_FOLDER}"/scripts/package.sh
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
#     Instead, edit ./helpers/make-package.sh     #
###################################################

# make sure we are home
cd /home/grafana || exit

sudo bash -c "cat > /etc/yum.repos.d/grafana.repo" <<"EOG"
#!/bin/bash

[grafana]
name=grafana
baseurl=https://packages.grafana.com/${GF_LICENSE}/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOG

sudo yum update -y grafana${DEB_TAG}
sudo yum install -y grafana${DEB_TAG}-7.5.1
sudo yum update -y grafana${DEB_TAG}

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT
fi
}
