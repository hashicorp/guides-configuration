#!/bin/bash
set -x

echo "Running"

ENVCONSUL_VERSION=${VERSION:-0.6.2}
ENVCONSUL_ZIP=envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip
ENVCONSUL_URL=${URL:-https://releases.hashicorp.com/envconsul/${ENVCONSUL_VERSION}/${ENVCONSUL_ZIP}}
ENVCONSUL_USER=${USER:-envconsul}
ENVCONSUL_GROUP=${GROUP:-envconsul}
CONFIG_DIR=/etc/envconsul.d
DATA_DIR=/opt/envconsul/data
DOWNLOAD_DIR=/tmp

echo "Downloading envconsul ${ENVCONSUL_VERSION}"
curl --silent --output ${DOWNLOAD_DIR}/${ENVCONSUL_ZIP} ${ENVCONSUL_URL}

echo "Installing envconsul"
sudo unzip -o ${DOWNLOAD_DIR}/${ENVCONSUL_ZIP} -d /usr/local/bin/
sudo chmod 0755 /usr/local/bin/envconsul
sudo chown ${ENVCONSUL_USER}:${ENVCONSUL_GROUP} /usr/local/bin/envconsul

echo "/usr/local/bin/envconsul --version: $(/usr/local/bin/envconsul --version)"

echo "Configuring envconsul"
sudo mkdir -pm 0755 ${CONFIG_DIR} ${DATA_DIR}
sudo chown -R ${ENVCONSUL_USER}:${ENVCONSUL_GROUP} ${CONFIG_DIR} ${DATA_DIR}
sudo chmod -R 0644 ${CONFIG_DIR}/*

echo "Complete"
