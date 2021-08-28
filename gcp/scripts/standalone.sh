#!/bin/bash

# make sure we are home
cd /home/grafana

# packages
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y adduser libfontconfig1 wget tmux

# download Grafana
wget https://dl.grafana.com/${LICENSE}/release/${VERSION}.${ARCH}.tar.gz
tar -zxvf ${VERSION}.${ARCH}.tar.gz

# start grafana-server in detached tmux session
cd /home/grafana/${VERSION}
tmux new -d -s grafanaServer
tmux send-keys -t grafanaServer.0 "./bin/grafana-server web" ENTER