#!/bin/bash

# packages
cd /home/grafana
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common
sudo apt-get install -y build-essential
# sudo apt-get install -y make

# set UFW (use gcp firewall rules)
# sudo ufw allow proto tcp from any to any port 22
# sudo ufw --force enable
# sudo ufw allow OpenSSH
# sudo ufw allow 3000
# sudo ufw reload

# raise open file limit
ulimit -S -n 2048

# nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
. /home/grafana/.bashrc

# node
nvm install --lts

# yarn
npm install --global yarn

# go
git clone https://github.com/canha/golang-tools-install-script.git
. ./golang-tools-install-script/goinstall.sh
. /home/grafana/.bashrc

# grafana/grafana repo
git clone https://github.com/grafana/grafana.git

# yarn install
cd /home/grafana/grafana
yarn install --pure-lockfile

# start frontend in tmux session
tmux new -d -s grafanaFrontend
tmux send-keys -t grafanaFrontend.0 "yarn start" ENTER

# start backend in tmux session
tmux new -d -s grafanaBackend
tmux send-keys -t grafanaBackend.0 "make run" ENTER