#!/usr/bin/env bash
set -x

echo "Running"

NOMAD_VERSION="${VERSION}"
NOMAD_ZIP="nomad_${NOMAD_VERSION}_linux_amd64.zip"
NOMAD_URL=${URL:-https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/${NOMAD_ZIP}}
NOMAD_DIR=/usr/local/bin
NOMAD_PATH=${NOMAD_DIR}/nomad
NOMAD_CONFIG_DIR=/etc/nomad.d
NOMAD_DATA_DIR=/opt/nomad/data
NOMAD_TLS_DIR=/opt/nomad/tls
NOMAD_ENV_VARS=${NOMAD_CONFIG_DIR}/nomad.conf
NOMAD_PROFILE_SCRIPT=/etc/profile.d/nomad.sh

echo "Downloading nomad ${NOMAD_VERSION}"
[200 -ne $(curl --write-out %{http_code} --silent --output /tmp/${NOMAD_ZIP} ${NOMAD_URL})] && exit 1

echo "Installing nomad"
sudo unzip -o /tmp/${NOMAD_ZIP} -d ${NOMAD_DIR}
sudo chmod 0755 ${NOMAD_PATH}
sudo chown ${USER}:${GROUP} ${NOMAD_PATH}
echo "$(${NOMAD_PATH} --version)"

echo "Configuring nomad ${NOMAD_VERSION}"
sudo mkdir -pm 0755 ${NOMAD_CONFIG_DIR} ${NOMAD_DATA_DIR} ${NOMAD_TLS_DIR}

# Start Nomad in -dev mode
echo "FLAGS=-dev" | sudo tee ${NOMAD_ENV_VARS}

sudo chown -R ${USER}:${GROUP} ${NOMAD_CONFIG_DIR} ${NOMAD_DATA_DIR} ${NOMAD_TLS_DIR}
sudo chmod -R 0644 ${NOMAD_CONFIG_DIR}/*

echo "export NOMAD_ADDR=http://127.0.0.1:4646" | sudo tee ${NOMAD_PROFILE_SCRIPT}

source ${NOMAD_PROFILE_SCRIPT}

echo "Complete"
