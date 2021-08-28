#!/bin/bash

# make sure we are home
cd /home/grafana

# packages
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y adduser libfontconfig1 wget

# get binary (not the standalone)
wget https://dl.grafana.com/oss/release/grafana_7.5.9_amd64.deb
sudo dpkg -i grafana_7.5.9_amd64.deb

# start and add to systemd
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
