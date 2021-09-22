#!/bin/bash

ACTUAL_FILE_SIZE=$(curl -vo /dev/null https://packages.grafana.com/oss/deb/dists/stable/main/binary-amd64/Packages.bz2 -w '%{size_download}\n')
LISTED_FILE_SIZE=$(curl -s https://packages.grafana.com/oss/deb/dists/stable/InRelease | grep -m 1 main/binary-amd64/Packages.bz2 | awk '{print $2}')
IP=$(curl -s icanhazip.com)
ZONE=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google" | sed 's/projects.*zones\///')
ID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/id" -H "Metadata-Flavor: Google")

# for investigations: save above variables & curl outputs to disk
curl -vo /dev/null https://packages.grafana.com/oss/deb/dists/stable/main/binary-amd64/Packages.bz2 -w '%{size_download}' > ./actual-file-size.txt 2> actual-curl-log.txt
curl -v /dev/null https://packages.grafana.com/oss/deb/dists/stable/InRelease > ./listed-file-size.txt 2> listed-curl-log.txt    
    
if ! [[ "${ACTUAL_FILE_SIZE}" == "${LISTED_FILE_SIZE}" ]]; then
    curl -X POST http://35.238.143.7:3000/admin \
    -H 'authorization: Basic Zm9vOmJhcg==' \
    -H 'content-type: application/json' \
    -d '{"zone":"'"${ZONE}"'", "ip":"'"${IP}"'", "id":"'"${ID}"'", "test":"0"}'
else
    curl -X POST http://35.238.143.7:3000/admin \
    -H 'authorization: Basic Zm9vOmJhcg==' \
    -H 'content-type: application/json' \
    -d '{"zone":"'"${ZONE}"'", "ip":"'"${IP}"'", "id":"'"${ID}"'", "test":"1"}'
fi
