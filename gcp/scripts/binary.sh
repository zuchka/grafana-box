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
sudo yum update -y
sudo yum install -y https://dl.grafana.com/oss/release/grafana--1.x86_64.rpm

# add to systemd and start
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
