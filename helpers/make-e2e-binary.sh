#!/bin/bash

# create new devenv setup script with injected vars
function makeE2eBinary () {
  if [[ ${IMAGE_FAMILY} =~ (ubuntu|debian) ]]; then
    cat <<EOT > ./"${GFB_FOLDER}"/scripts/e2e-binary.sh
#!/bin/bash

# packages
sudo apt update -y
sudo apt install -y libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 
sudo apt install -y xauth xvfb 
sudo apt install -y wget adduser tmux git

# get standalone binary
wget https://dl.grafana.com/oss/release/grafana-${TEST_BINARY}.linux-amd64.tar.gz
tar -zxvf grafana-${TEST_BINARY}.linux-amd64.tar.gz
cd grafana-${TEST_BINARY} || return

# start binary in detached tmux session
tmux new -d -s grafanaBinary
tmux send-keys -t grafanaBinary.0 "./bin/grafana-server cfg:server.http_port=3001" ENTER
cd 

# make sure we are home again
cd /home/grafana || return

# raise open file limit
ulimit -S -n 2048

# install nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
[ -s "/home/grafana/.nvm/nvm.sh" ] && \. "/home/grafana/.nvm/nvm.sh"  # This loads nvm
[ -s "/home/grafana/.nvm/bash_completion" ] && \. "/home/grafana/.nvm/bash_completion"  # This loads nvm bash_completion
. "/home/grafana/.bashrc"

# install node
nvm install ${NODE_VERSION}
. "/home/grafana/.bashrc"

# install yarn
npm install --global yarn

# clone grafana/grafana repo
git config --global core.autocrlf input
git clone https://github.com/grafana/grafana.git

# check out chosen branch
cd /home/grafana/grafana || return
git checkout -b test-${BRANCH} origin/${BRANCH}
git pull

# replace cypress config so we can save JSON to file
function makeCypressJson () {
  cat <<EOF > ./packages/grafana-e2e/cypress.json
{
  "projectId": "zb7k1c",
  "supportFile": "cypress/support/index.ts",
  "reporter": "mochawesome",
    "reporter-option": {  
      "html": "false",
      "json": "true"
    }
}
EOF
}

makeCypressJson

# add mochawesome to packages/grafana-e2e
npm install --prefix ./packages/grafana-e2e mochawesome

# run yarn install
yarn install --pure-lockfile

# use electron and not chrome for e2e tests
sed -i 's/chrome/electron/' packages/grafana-e2e/package.json

# start release e2e test
. ./e2e/verify-release

EOT
  # Cent 7 default Git is too old.
  elif [[ ${DISTRO} =~ centos-7 ]]; then
    cat <<EOT > ./"${GFB_FOLDER}"/scripts/e2e-binary.sh
#!/bin/bash

###################################################
#                                                 #
#                  WARNING!                       #
#                                                 #
#  do not make edits to ./gcp/scripts/e2e-binary.sh   #
#                                                 #
#  a new version with updated variables           #
#  will overwrite this file every time you run    #
#  ./grafana-box.sh.                              #
#                                                 #
#     Instead, edit ./helpers/make-e2e-binary.sh      #
###################################################

# make sure we are home
cd /home/grafana || return

# only for Cent7. Default Git version is too old
sudo yum -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.9-1.x86_64.rpm

# packages
sudo yum update -y xorg-x11-server-Xvfb gtk2-devel gtk3-devel libnotify-devel GConf2 nss libXScrnSaver alsa-lib tmux wget
sudo yum install -y xorg-x11-server-Xvfb gtk2-devel gtk3-devel libnotify-devel GConf2 nss libXScrnSaver alsa-lib
sudo yum install -y tmux wget git


# get standalone binary
wget https://dl.grafana.com/oss/release/grafana-${TEST_BINARY}.linux-amd64.tar.gz
tar -zxvf grafana-${TEST_BINARY}.linux-amd64.tar.gz
cd grafana-${TEST_BINARY} || return

# start binary in detached tmux session
tmux new -d -s grafanaBinary
tmux send-keys -t grafanaBinary.0 "./bin/grafana-server cfg:server.http_port=3001" ENTER
cd 

# make sure we are home again
cd /home/grafana || return

# raise open file limit
ulimit -S -n 2048

# install nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
[ -s "/home/grafana/.nvm/nvm.sh" ] && \. "/home/grafana/.nvm/nvm.sh"  # This loads nvm
[ -s "/home/grafana/.nvm/bash_completion" ] && \. "/home/grafana/.nvm/bash_completion"  # This loads nvm .nvm/bash_completion
. "/home/grafana/.bashrc"

# install node
nvm install ${NODE_VERSION}
. "/home/grafana/.bashrc"

# install yarn
npm install --global yarn

# clone grafana/grafana repo
git config --global core.autocrlf input
git clone https://github.com/grafana/grafana.git

# check out chosen branch
cd /home/grafana/grafana || return
git checkout -b test-${BRANCH} origin/${BRANCH}
git pull

# replace cypress config so we can save JSON to file
function makeCypressJson () {
  cat <<EOF > ./packages/grafana-e2e/cypress.json
{
  "projectId": "zb7k1c",
  "supportFile": "cypress/support/index.ts",
  "reporter": "mochawesome",
    "reporter-option": {  
      "html": "false",
      "json": "true"
    }
}
EOF
}

makeCypressJson

# add mochawesome to packages/grafana-e2e
npm install --prefix ./packages/grafana-e2e mochawesome

# run yarn install
yarn install --pure-lockfile

# use electron and not chrome for e2e tests
sed -i 's/chrome/electron/' packages/grafana-e2e/package.json

# start release e2e test
. ./e2e/verify-release

EOT
  elif [[ ${IMAGE_FAMILY} =~ (centos|rocky) ]]; then
  cat <<EOT > ./"${GFB_FOLDER}"/scripts/e2e-binary.sh
#!/bin/bash

###################################################
#                                                 #
#                  WARNING!                       #
#                                                 #
#  do not make edits to ./gcp/scripts/e2e-binary.sh   #
#                                                 #
#  a new version with updated variables           #
#  will overwrite this file every time you run    #
#  ./grafana-box.sh.                              #
#                                                 #
#     Instead, edit ./helpers/make-e2e-binary.sh      #
###################################################

# make sure we are home
cd /home/grafana || return

# packages
sudo yum update -y xorg-x11-server-Xvfb gtk2-devel gtk3-devel libnotify-devel GConf2 nss libXScrnSaver alsa-lib tmux wget git
sudo yum install -y xorg-x11-server-Xvfb gtk2-devel gtk3-devel libnotify-devel GConf2 nss libXScrnSaver alsa-lib
sudo yum install -y tmux wget git

# get standalone binary
wget https://dl.grafana.com/oss/release/grafana-${TEST_BINARY}.linux-amd64.tar.gz
tar -zxvf grafana-${TEST_BINARY}.linux-amd64.tar.gz
cd grafana-${TEST_BINARY} || return

# start binary in detached tmux session
tmux new -d -s grafanaBinary
tmux send-keys -t grafanaBinary.0 "./bin/grafana-server cfg:server.http_port=3001" ENTER
cd 

# make sure we are home again
cd /home/grafana || return

# raise open file limit
ulimit -S -n 2048

# install nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
[ -s "/home/grafana/.nvm/nvm.sh" ] && \. "/home/grafana/.nvm/nvm.sh"  # This loads nvm
[ -s "/home/grafana/.nvm/bash_completion" ] && \. "/home/grafana/.nvm/bash_completion"  # This loads nvm .nvm/bash_completion
. /home/grafana/.bashrc

# install node
nvm install ${NODE_VERSION}
. "/home/grafana/.bashrc"

# install yarn
npm install --global yarn

# clone grafana/grafana repo
git config --global core.autocrlf input
git clone https://github.com/grafana/grafana.git

# check out chosen branch
cd /home/grafana/grafana || return
git checkout -b test-${BRANCH} origin/${BRANCH}
git pull

# replace cypress config so we can save JSON to file
function makeCypressJson () {
  cat <<EOF > ./packages/grafana-e2e/cypress.json
{
  "projectId": "zb7k1c",
  "supportFile": "cypress/support/index.ts",
  "reporter": "mochawesome",
    "reporter-option": {  
      "html": "false",
      "json": "true"
    }
}
EOF
}

makeCypressJson

# add mochawesome to packages/grafana-e2e
npm install --prefix ./packages/grafana-e2e mochawesome

# run yarn install
yarn install --pure-lockfile

# use electron and not chrome for e2e tests
sed -i 's/chrome/electron/' packages/grafana-e2e/package.json

# start release e2e test
. ./e2e/verify-release
EOT
fi
}
