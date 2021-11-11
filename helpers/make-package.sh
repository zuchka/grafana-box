#!/bin/bash

function makePackage () {
  if [[ -z ${MANUAL_PACKAGE} ]]; then
    makePackageManager
  else
    makePackageManual
  fi
}

# use YUM or APT
function makePackageManager () {
  if [[ ${IMAGE_FAMILY} =~ (ubuntu|debian) ]]; then
    cat <<EOT > ./"${GFB_FOLDER}"/scripts/package.sh
#!/bin/bash

# packages
cd /home/grafana || exit
sudo apt install -y apt-transport-https
sudo apt install -y libfontconfig1
sudo apt install -y software-properties-common wget

wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/${GF_LICENSE}/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

sudo apt update  -y
sudo apt install -y grafana${DEB_TAG}=7.5.1
sudo apt clean
sudo apt upgrade -y grafana${DEB_TAG}

# add to systemd and start
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT
  elif [[ ${IMAGE_FAMILY} =~ (centos|rocky) ]]; then
  cat <<EOT > ./"${GFB_FOLDER}"/scripts/package.sh
#!/bin/bash

# make sure we are home
cd /home/grafana || exit

sudo bash -c "cat > /etc/yum.repos.d/grafana.repo" <<"EOG"
#!/bin/bash
[grafana]
name=grafana
baseurl=https://packages.grafana.com/${GF_LICENSE}/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOG

# sudo yum update -y grafana${DEB_TAG}
# sudo yum install -y grafana${DEB_TAG}-7.5.1
sudo yum update -y grafana${DEB_TAG}

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT
  fi
}


# use WGET + DPKG
function makePackageManual () {
  if [[ ${IMAGE_FAMILY} =~ (ubuntu|debian) ]]; then
    cat <<EOT > ./"${GFB_FOLDER}"/scripts/package.sh
#!/bin/bash

# packages
cd /home/grafana || exit
sudo apt install -y apt-transport-https
sudo apt install -y libfontconfig1 adduser
sudo apt install -y software-properties-common wget

# manual install workflow
wget https://dl.grafana.com/${GF_LICENSE}/release/grafana${DEB_TAG}_${MANUAL_PACKAGE_VERSION}_amd64.deb
sudo dpkg -i grafana${DEB_TAG}_${MANUAL_PACKAGE_VERSION}_amd64.deb

# add to systemd and start
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT
  elif [[ ${IMAGE_FAMILY} =~ (centos|rocky) ]]; then
  cat <<EOT > ./"${GFB_FOLDER}"/scripts/package.sh
#!/bin/bash

# make sure we are home
cd /home/grafana || exit

sudo bash -c "cat > /etc/yum.repos.d/grafana.repo" <<"EOG"
#!/bin/bash

[grafana]
name=grafana
baseurl=https://packages.grafana.com/${GF_LICENSE}/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOG

sudo yum update -y grafana${DEB_TAG}
sudo yum install -y grafana${DEB_TAG}-${MANUAL_PACKAGE_VERSION}
sudo yum update -y grafana${DEB_TAG}

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT
  fi
}
