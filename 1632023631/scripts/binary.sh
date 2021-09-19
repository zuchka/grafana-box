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
cd /home/grafana || return

# packages
sudo apt-get update -y
sudo apt-get install -y wget tmux 

# get standalone binary
wget https://dl.grafana.com/oss/release/grafana-.linux-amd64.tar.gz
tar -zxvf grafana-.linux-amd64.tar.gz
cd grafana- || exit

# start binary in detached tmux session
tmux new -d -s grafanaBinary
tmux send-keys -t grafanaBinary.0 "./bin/grafana-server" ENTER
