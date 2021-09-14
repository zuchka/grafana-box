#!/bin/bash

# create new binary setup script with injected vars
function makeBinary () {
  if [[ ${IMAGE_FAMILY} =~ (ubuntu|debian) ]]; then
    cat <<EOT > ./${GFB_FOLDER}/scripts/binary.sh
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
#     Instead, edit ./helpers/make-binary.sh      #
###################################################

# make sure we are home
cd /home/grafana

# packages
sudo apt-get update -y
# sudo apt-get upgrade -y
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
  cat <<EOT > ./${GFB_FOLDER}/scripts/binary.sh
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
#     Instead, edit ./helpers/make-binary.sh      #
###################################################

# make sure we are home
cd /home/grafana

# get binary (not the standalone)
# sudo yum update -y
sudo yum install -y https://dl.grafana.com/oss/release/grafana-${GF_VERSION}-1.x86_64.rpm

# add to systemd and start
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT
fi
}
