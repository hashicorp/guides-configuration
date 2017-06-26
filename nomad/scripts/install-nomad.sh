#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT $0: $1"
}

logger "Running"

NOMAD_VERSION="${VERSION}"
NOMAD_ZIP="nomad_${NOMAD_VERSION}_linux_amd64.zip"
NOMAD_URL=${URL:-"https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/${NOMAD_ZIP}"}
NOMAD_USER="nomad"
NOMAD_GROUP="nomad"
CONFIG_DIR="/etc/nomad.d"
DATA_DIR="/opt/nomad/data"
DOWNLOAD_DIR="/tmp"

logger "Downloading nomad ${NOMAD_VERSION}"
curl --silent --output ${DOWNLOAD_DIR}/${NOMAD_ZIP} ${NOMAD_URL}

logger "Installing nomad"
sudo unzip -o ${DOWNLOAD_DIR}/${NOMAD_ZIP} -d /usr/local/bin/
sudo chmod 0755 /usr/local/bin/nomad
sudo chown ${NOMAD_USER}:${NOMAD_GROUP} /usr/local/bin/nomad
sudo mkdir -pm 0755 ${CONFIG_DIR} ${DATA_DIR}
sudo cp /tmp/nomad/config/*.example ${CONFIG_DIR}
sudo chown -R ${NOMAD_USER}:${NOMAD_GROUP} ${CONFIG_DIR} ${DATA_DIR}
sudo chmod -R 0644 ${CONFIG_DIR}/*

logger "/usr/local/bin/nomad --version: $(/usr/local/bin/nomad --version)"

logger "Complete"
