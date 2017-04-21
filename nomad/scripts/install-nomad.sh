#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  FILENAME="install-nomad.sh"
  echo "$DT $FILENAME: $1"
}

logger "Running"

NOMAD_VERSION=${VERSION:-"0.5.6"}
NOMAD_ZIP="nomad_${NOMAD_VERSION}_linux_amd64.zip"
NOMAD_URL=${URL:-"https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/${NOMAD_ZIP}"}
NOMAD_CLIENT=${CLIENT:-}
NOMAD_SERVER=${SERVER:-}
NOMAD_CONSUL=${CONSUL:-}
NOMAD_USER=${USER:-"nomad"}
NOMAD_GROUP=${GROUP:-"nomad"}
CONFIG_DIR="/etc/nomad.d"
DATA_DIR="/opt/nomad/data"
DOWNLOAD_DIR="/tmp"

logger "Downloading nomad ${NOMAD_VERSION}"
curl --silent --output ${DOWNLOAD_DIR}/${NOMAD_ZIP} ${NOMAD_URL}

logger "Installing nomad"
sudo unzip -o ${DOWNLOAD_DIR}/${NOMAD_ZIP} -d /usr/local/bin/
sudo chmod 0755 /usr/local/bin/nomad
sudo chown ${NOMAD_USER}:${NOMAD_GROUP} /usr/local/bin/nomad

logger "/usr/local/bin/nomad --version: $(/usr/local/bin/nomad --version)"

logger "Configuring nomad"
sudo mkdir -pm 0755 ${CONFIG_DIR} ${DATA_DIR}
sudo cp /tmp/nomad/config/nomad-default.hcl ${CONFIG_DIR}
if [[ ${NOMAD_CLIENT} = "true" ]]; then
  logger "Configuring nomad as a client"
  sudo cp /tmp/nomad/config/nomad-client.hcl ${CONFIG_DIR}
fi
if [[ ${NOMAD_SERVER} = "true" ]]; then
  logger "Configuring nomad as a server"
  sudo cp /tmp/nomad/config/nomad-server.hcl ${CONFIG_DIR}
fi
if [[ ${NOMAD_CONSUL} = "true" ]]; then
  logger "Configuring nomad/consul"
  sudo cp /tmp/nomad/config/nomad-consul.hcl ${CONFIG_DIR}
fi
sudo chown -R ${NOMAD_USER}:${NOMAD_GROUP} ${CONFIG_DIR} ${DATA_DIR}
sudo chmod -R 0644 ${CONFIG_DIR}/*

logger "Complete"
