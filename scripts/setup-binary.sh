#!/bin/bash

# make sure we are home
cd /home/grafana

# download Grafana
wget https://dl.grafana.com/oss/release/grafana-8.1.2.linux-amd64.tar.gz
tar -zxvf grafana-8.1.2.linux-amd64.tar.gz

# start grafana-server in detached tmux session
cd /home/grafana/grafana-8.1.2
tmux new -d -s grafanaServer
tmux send-keys -t grafanaServer.0 "./bin/grafana-server web" ENTER
