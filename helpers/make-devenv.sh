#!/bin/bash

function makeDevenv () {
  downloadTooling
  buildDevenv
}

function downloadTooling () {
  if [[ ${IMAGE_FAMILY} =~ (ubuntu|debian) ]]; then
    cat <<EOT > ./"${GFB_FOLDER}"/scripts/devenv.sh
#!/bin/bash

# make sure we are home
cd /home/grafana || return

sudo apt update -y
sudo apt install -y build-essential 
sudo apt install -y libfontconfig1 
sudo apt install -y wget adduser tmux git
EOT
  # Cent 7 default Git is too old.
  elif [[ ${DISTRO} =~ centos-7 ]]; then
    cat <<EOT > ./"${GFB_FOLDER}"/scripts/devenv.sh
#!/bin/bash

# make sure we are home
cd /home/grafana || return

# only for Cent7. Default Git version is too old
sudo yum -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.9-1.x86_64.rpm

# packages
sudo yum update -y gcc gcc-c++ kernel-devel make tmux wget
sudo yum install -y gcc gcc-c++ kernel-devel make tmux wget git
EOT
  elif [[ ${IMAGE_FAMILY} =~ (centos|rocky) ]]; then
  cat <<EOT > ./"${GFB_FOLDER}"/scripts/devenv.sh
#!/bin/bash

# make sure we are home
cd /home/grafana || return

# packages
sudo yum update -y gcc gcc-c++ kernel-devel make tmux wget git
sudo yum install -y gcc gcc-c++ kernel-devel make tmux wget git
EOT
fi
}

function buildDevenv () {
  cat <<EOT >> ./"${GFB_FOLDER}"/scripts/devenv.sh

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

# install go
git clone https://github.com/canha/golang-tools-install-script.git
. "./golang-tools-install-script/goinstall.sh"
. "/home/grafana/.bashrc"

# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# add docker to systemd 
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo systemctl start docker.service
sudo systemctl start containerd.service

# install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Linux-x86_64" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose

# clone grafana/grafana repo
git clone https://github.com/grafana/grafana.git

# check out chosen branch
cd /home/grafana/grafana || return
git config --global core.autocrlf input
git checkout -b test-${BRANCH} origin/${BRANCH}
git pull

# build devenv DBs
. "/home/grafana/.bashrc"
sudo make devenv sources=${DUMMY_DBS}

# run yarn install
yarn install --pure-lockfile

# start frontend in tmux session
tmux new -d -s grafanaFrontend
tmux send-keys -t grafanaFrontend.0 "yarn start" ENTER

# start backend in tmux session
tmux new -d -s grafanaBackend
tmux send-keys -t grafanaBackend.0 "make run" ENTER
EOT
}