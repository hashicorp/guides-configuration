#!/bin/bash
set -x

echo "Running"

VAULT_SI_VERSION=${VERSION:-"0.18.2"}
VAULT_SI_ZIP="vault-si_${VAULT_SI_VERSION}_linux_amd64.zip"
VAULT_SI_URL=${URL:-}
VAULT_SI_USER=${USER:-"vault-si"}
VAULT_SI_GROUP=${GROUP:-"vault-si"}
CONFIG_DIR="/etc/vault-si.d"
DATA_DIR="/opt/vault-si/data"
DOWNLOAD_DIR="/tmp"

echo "Downloading vault-si ${VAULT_SI_VERSION}"
curl --silent --output ${DOWNLOAD_DIR}/${VAULT_SI_ZIP} ${VAULT_SI_URL}

echo "Installing vault-si"
sudo unzip -o ${DOWNLOAD_DIR}/${VAULT_SI_ZIP} -d /usr/local/bin/
sudo chmod 0755 /usr/local/bin/vault-si
sudo chown ${VAULT_SI_USER}:${VAULT_SI_GROUP} /usr/local/bin/vault-si

echo "/usr/local/bin/vault-si --version: $(/usr/local/bin/vault-si --version)"

echo "Configuring vault-si"
sudo mkdir -pm 0755 ${CONFIG_DIR} ${DATA_DIR}
sudo cp /tmp/vault-si/config/vault-si.hcl ${CONFIG_DIR}

sudo chown -R ${VAULT_SI_USER}:${VAULT_SI_GROUP} ${CONFIG_DIR} ${DATA_DIR}
sudo chmod -R 0644 ${CONFIG_DIR}/*

echo "Complete"
