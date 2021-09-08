#!/bin/bash

###################################################
#                                                 #
#                  WARNING!                       #
#                                                 #
#  do not make edits to ./gcp/scripts/devenv.sh   #
#                                                 #
#  a new version with updated variables           #
#  will overwrite this file every time you run    #
#  ./grafana-box.sh.                              #
#                                                 #
#     Instead, edit ./helpers/make-devenv.sh      #
###################################################

# make sure we are home
cd /home/grafana

# packages
sudo yum install -y gcc gcc-c++ kernel-devel make tmux wget git

# raise open file limit
ulimit -S -n 2048

# install nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export GF_NVM_DIR="/home/grafana/.nvm"
[ -s "/home/grafana/.nvm/nvm.sh" ] && \. "/home/grafana/.nvm/nvm.sh"  # This loads nvm
[ -s "/home/grafana/.nvm/bash_completion" ] && \. "/home/grafana/.nvm/bash_completion"  # This loads nvm .nvm/bash_completion
. /home/grafana/.bashrc

# install node
nvm install --lts

# install yarn
npm install --global yarn

# install go
git clone https://github.com/canha/golang-tools-install-script.git
. ./golang-tools-install-script/goinstall.sh
. /home/grafana/.bashrc

# clone grafana/grafana repo
git clone https://github.com/grafana/grafana.git

# check out chosen branch
cd /home/grafana/grafana
git fetch origin
git checkout -b test-cloudwatch/workspace-iam-role-auth origin/cloudwatch/workspace-iam-role-auth

# run yarn install
yarn install --pure-lockfile

# start frontend in tmux session
tmux new -d -s grafanaFrontend
tmux send-keys -t grafanaFrontend.0 "yarn start" ENTER

# start backend in tmux session
tmux new -d -s grafanaBackend
tmux send-keys -t grafanaBackend.0 "make run" ENTER
