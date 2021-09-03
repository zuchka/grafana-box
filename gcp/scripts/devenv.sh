#!/bin/bash

###################################################
#                                                 #
#                  WARNING!                       #
#                                                 #
#  do not make edits to this file (devenv.sh)    #
#  a new version with updated variables           #
#  will overwrite this file every time you run    #
#  ./grafana-box.sh.                              #
#                                                 #
#        Instead, edit grafana-box.sh:lines       #
###################################################

#!/bin/bash

# make sure we are home
cd /home/grafana

# packages
sudo yum install -y gcc gcc-c++ kernel-devel make tmux wget git

# raise open file limit
ulimit -S -n 2048

# install nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export NVM_DIR="/Users/zuchka/.nvm"
[ -s "/Users/zuchka/.nvm/nvm.sh" ] && \. "/Users/zuchka/.nvm/nvm.sh"  # This loads nvm
[ -s "/Users/zuchka/.nvm/bash_completion" ] && \. "/Users/zuchka/.nvm/bash_completion"  # This loads nvm bash_completion
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

# run yarn install
cd /home/grafana/grafana
yarn install --pure-lockfile

# start frontend in tmux session
tmux new -d -s grafanaFrontend
tmux send-keys -t grafanaFrontend.0 "yarn start" ENTER

# start backend in tmux session
tmux new -d -s grafanaBackend
tmux send-keys -t grafanaBackend.0 "make run" ENTER
