#!/bin/bash

ACTUAL_FILE_SIZE=$(curl -vo /dev/null https://packages.grafana.com/oss/deb/dists/stable/main/binary-amd64/Packages.bz2 -w '%{size_download}\n')
LISTED_FILE_SIZE=$(curl -s https://packages.grafana.com/oss/deb/dists/stable/InRelease | grep -m 1 main/binary-amd64/Packages.bz2 | awk '{print $2}')


# for investigations: save above variables & curl outputs to disk
curl -vo /dev/null https://packages.grafana.com/oss/deb/dists/stable/main/binary-amd64/Packages.bz2 -w '%{size_download}' > ./actual-file-size.txt 2> actual-curl-log.txt
curl -v /dev/null https://packages.grafana.com/oss/deb/dists/stable/InRelease > ./listed-file-size.txt 2> listed-curl-log.txt    
    
if ! [[ "${ACTUAL_FILE_SIZE}" == "${LISTED_FILE_SIZE}" ]]; then
    cat <<EOH >> ./checksum-test.txt
FAIL
these checksums did not match
EOH
else
    cat <<EOM >> ./checksum-test.txt
SUCCESS
these checksums match
EOM
fi

# cp ./"${GFB_FOLDER}"/scripts/centos-cloud-test.sh ./"${GFB_FOLDER}"/scripts/rocky-linux-cloud-test.sh 
# cp ./"${GFB_FOLDER}"/scripts/centos-cloud-test.sh ./"${GFB_FOLDER}"/scripts/ubuntu-os-cloud-test.sh 
# cp ./"${GFB_FOLDER}"/scripts/centos-cloud-test.sh ./"${GFB_FOLDER}"/scripts/debian-cloud-test.sh
