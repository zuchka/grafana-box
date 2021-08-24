#!/bin/bash

# packages
cd /home/grafana
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install make
# # i need GCC as well

# # nvm
# wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# . /home/grafana/.bashrc

# # node
# nvm install --lts

# # yarn
# npm install --global yarn

# # go
# git clone https://github.com/canha/golang-tools-install-script.git
# . ./golang-tools-install-script/goinstall.sh
# . /home/grafana/.bashrc

# # Grafana repo
# git clone https://github.com/grafana/grafana.git

# # yarn install
# cd /home/grafana/grafana
# yarn install --pure-lockfile



sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common

# set UFW
sudo ufw allow proto tcp from any to any port 22
sudo ufw --force enable
sudo ufw allow OpenSSH
sudo ufw allow 3000
sudo ufw reload

# download Grafana
wget https://dl.grafana.com/oss/release/grafana-8.1.2.linux-amd64.tar.gz
tar -zxvf grafana-8.1.2.linux-amd64.tar.gz

# start grafana-server
cd /home/grafana/grafana-8.1.2
tmux new -d -s grafanaServer
tmux send-keys -t grafanaServer.0 "./bin/grafana-server web" ENTER





#    32  wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
#    33  echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
#    34  sudo apt-get update
#    35  sudo apt-get install grafana