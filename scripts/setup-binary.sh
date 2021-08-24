#!/bin/bash

# make sure we are home
cd /home/grafana

# set UFW
sudo ufw allow proto tcp from any to any port 22
sudo ufw --force enable
sudo ufw allow OpenSSH
sudo ufw allow 3000
sudo ufw reload

# download Grafana
wget https://dl.grafana.com/oss/release/grafana-8.1.2.linux-amd64.tar.gz
tar -zxvf grafana-8.1.2.linux-amd64.tar.gz

# start grafana-server in detached tmux session
cd /home/grafana/grafana-8.1.2
tmux new -d -s grafanaServer
tmux send-keys -t grafanaServer.0 "./bin/grafana-server web" ENTER
