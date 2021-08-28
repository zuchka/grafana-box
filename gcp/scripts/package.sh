#!/bin/bash

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

# start and add to systemd
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server

# working on
#
# debian-11
# debian-10
# debian-9
# ubuntu-2004-lts
# ubuntu-1804-lts
# ubuntu-1604-lts