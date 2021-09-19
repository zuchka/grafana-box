#!/bin/bash

function testPackage () {
    terraform -chdir="${GFB_FOLDER}"/ \
      output -json instance_ip | jq -r '.[][].address' \
        > "${GFB_FOLDER}/ip.txt"
    
    while read -r IP; do
        LOGIN_CHECK=$(curl -s http://"$IP":3000 | grep -c "login")
        if [ "$LOGIN_CHECK" == 1 ] ; then
            printf "%33b ................. %b\n" \
            "checking for Grafana login page" "SUCCESS\n" \
            "web login" "curl http://${IP}:3000" \
            "vm login"  "ssh  grafana@${IP}\n\n"
        else
            printf "%33b ................. %b\n" \
            "checking for Grafana login page" "FAILURE\n" \
            "web login" "curl http://${IP}:3000" \
            "vm login"  "ssh  grafana@${IP}\n\n"     
        fi
    done < "${GFB_FOLDER}/ip.txt"
}

function testRpmPackage () {
  cat <<EOT > ./"${GFB_FOLDER}"/scripts/centos-cloud-test.sh
#!/bin/bash

# make sure we are home
cd /home/grafana || exit

sudo bash -c "cat > /etc/yum.repos.d/grafana.repo" <<"EOG"
#!/bin/bash

[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOG

sudo yum update -y grafana
sudo yum install -y grafana

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT

  cat <<EOT > ./"${GFB_FOLDER}"/scripts/rocky-linux-cloud-test.sh
#!/bin/bash

# make sure we are home
cd /home/grafana || exit

sudo bash -c "cat > /etc/yum.repos.d/grafana.repo" <<"EOG"
#!/bin/bash

[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOG

sudo yum update -y grafana
sudo yum install -y grafana

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT
}

function testDebPackage () {
  cat <<EOT > ./"${GFB_FOLDER}"/scripts/debian-cloud-test.sh
#!/bin/bash

# packages
cd /home/grafana || exit
sudo apt-get update -y
sudo apt-get install -y apt-transport-https 
sudo apt-get install -y software-properties-common wget

# install grafana
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update  -y
sudo apt-get install -y grafana

# add to systemd and start
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT

  cat <<EOT > ./"${GFB_FOLDER}"/scripts/ubuntu-os-cloud-test.sh
#!/bin/bash

# packages
cd /home/grafana || exit
sudo apt-get update -y
sudo apt-get install -y apt-transport-https 
sudo apt-get install -y software-properties-common wget

# install grafana
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update  -y
sudo apt-get install -y grafana

# add to systemd and start
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
EOT
}
