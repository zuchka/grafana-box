#!/bin/bash

# create new binary setup script with injected vars
function makeBinary () {
  if [[ ${IMAGE_FAMILY} =~ (ubuntu|debian) ]]; then
    cat <<EOT > ./"${GFB_FOLDER}"/scripts/binary.sh
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
wget https://dl.grafana.com/${GF_LICENSE}/release/grafana-${GF_TAG}${GF_VERSION}.linux-amd64.tar.gz
tar -zxvf grafana-${GF_TAG}${GF_VERSION}.linux-amd64.tar.gz
cd grafana-${GF_VERSION} || exit

# start binary in detached tmux session
tmux new -d -s grafanaBinary
tmux send-keys -t grafanaBinary.0 "./bin/grafana-server" ENTER
EOT
elif [[ ${IMAGE_FAMILY} =~ (centos|rocky) ]]; then
  cat <<EOT > ./"${GFB_FOLDER}"/scripts/binary.sh
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
cd /home/grafana || return

# get binary (not the standalone)
sudo yum install -y wget tmux

# get standalone binary
wget https://dl.grafana.com/oss/release/grafana-${GF_VERSION}.linux-amd64.tar.gz
tar -zxvf grafana-${GF_VERSION}.linux-amd64.tar.gz
cd grafana-${GF_VERSION} || exit

# start binary in detached tmux session
tmux new -d -s grafanaBinary
tmux send-keys -t grafanaBinary.0 "./bin/grafana-server" ENTER
EOT
fi
}
