#!/bin/bash

# TODO: add docker and dummy data
# TODO: add coder with grafana's dev setup

# create new devenv setup script with injected vars
function makeDevenv () {
  if [[ ${IMAGE_FAMILY} =~ (ubuntu|debian) ]]; then
    cat <<EOT > ./gcp/scripts/devenv.sh
#!/bin/bash

###################################################
#                                                 #
#                  WARNING!                       #
#                                                 #
#  do not make edits to this file (devenv.sh)     #
#  a new version with updated variables           #
#  will overwrite this file every time you run    #
#  ./grafana-box.sh.                              #
#                                                 #
#     Instead, edit ./helpers/make-devenv.sh      #
###################################################

#!/bin/bash

# make sure we are home
cd /home/grafana

# packages
sudo -S -k apt-get update -y
sudo -S -k apt-get upgrade -y
sudo -S -k apt-get install -y build-essential libfontconfig1 wget adduser tmux git make

# raise open file limit
ulimit -S -n 2048

# install nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
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
EOT
elif [[ ${IMAGE_FAMILY} =~ (centos|rocky) ]]; then
  cat <<EOT > ./gcp/scripts/devenv.sh
#!/bin/bash

###################################################
#                                                 #
#                  WARNING!                       #
#                                                 #
#  do not make edits to this file (devenv.sh)     #
#  a new version with updated variables           #
#  will overwrite this file every time you run    #
#  ./grafana-box.sh.                              #
#                                                 #
#     Instead, edit ./helpers/make-devenv.sh      #
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
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
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
EOT
fi
}