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
sudo apt-get update -y
sudo apt-get install -y apt-transport-https 
sudo apt-get install -y software-properties-common wget

# install grafana
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update  -y
sudo apt-get install -y grafana

# add to systemd and start
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
