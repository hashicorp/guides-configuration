#!/usr/bin/env bash
set -x

echo "Running"

VAULT_VERSION="${VERSION}"
VAULT_ZIP="vault_${VAULT_VERSION}_linux_amd64.zip"
VAULT_URL=${URL:-https://releases.hashicorp.com/vault/${VAULT_VERSION}/${VAULT_ZIP}}
VAULT_DIR=/usr/local/bin
VAULT_PATH=${VAULT_DIR}/vault
VAULT_CONFIG_DIR=/etc/vault.d
VAULT_DATA_DIR=/opt/vault/data
VAULT_TLS_DIR=/opt/vault/tls
VAULT_ENV_VARS=${VAULT_CONFIG_DIR}/vault.conf
VAULT_PROFILE_SCRIPT=/etc/profile.d/vault.sh

echo "Downloading vault ${VAULT_VERSION}"
[200 -ne $(curl --write-out %{http_code} --silent --output /tmp/${VAULT_ZIP} ${VAULT_URL})] && exit 1

echo "Installing vault"
sudo unzip -o /tmp/${VAULT_ZIP} -d ${VAULT_DIR}
sudo chmod 0755 ${VAULT_PATH}
sudo chown ${USER}:${GROUP} ${VAULT_PATH}
echo "$(${VAULT_PATH} --version)"

echo "Configuring vault ${VAULT_VERSION}"
sudo mkdir -pm 0755 ${VAULT_CONFIG_DIR} ${VAULT_DATA_DIR} ${VAULT_TLS_DIR}

# Start Vault in -dev mode
echo "FLAGS=-dev -dev-ha -dev-transactional -dev-root-token-id=root" | sudo tee ${VAULT_ENV_VARS}

sudo chown -R ${USER}:${GROUP} ${VAULT_CONFIG_DIR} ${VAULT_DATA_DIR} ${VAULT_TLS_DIR}
sudo chmod -R 0644 ${VAULT_CONFIG_DIR}/*

echo "export VAULT_ADDR=http://127.0.0.1:8200" | sudo tee ${VAULT_PROFILE_SCRIPT}
echo "export VAULT_TOKEN=root" | sudo tee -a ${VAULT_PROFILE_SCRIPT}

source ${VAULT_PROFILE_SCRIPT}

echo "Granting mlock syscall to vault binary"
sudo setcap cap_ipc_lock=+ep ${VAULT_PATH}

echo "Complete"
