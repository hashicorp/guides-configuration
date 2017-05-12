#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  FILENAME="install-vault.sh"
  echo "$DT $FILENAME: $1"
}

VAULT_VERSION="${VERSION}"
VAULT_ZIP="vault_${VAULT_VERSION}_linux_amd64.zip"
VAULT_URL=${URL:-"https://releases.hashicorp.com/vault/${VAULT_VERSION}/${VAULT_ZIP}"}
VAULT_CONSUL=${CONSUL:-}
VAULT_TLS=${TLS:-}
VAULT_USER=${USER:-"vault"}
VAULT_GROUP=${GROUP:-"vault"}
CONFIG_DIR="/etc/vault.d"
SSL_DIR="/etc/ssl/vault"
DOWNLOAD_DIR="/tmp"

logger "Downloading vault ${VAULT_VERSION}"
curl --silent --output ${DOWNLOAD_DIR}/${VAULT_ZIP} ${VAULT_URL}

logger "Installing vault"
sudo unzip -o ${DOWNLOAD_DIR}/${VAULT_ZIP} -d /usr/local/bin/
sudo chmod 0755 /usr/local/bin/vault
sudo chown ${VAULT_USER}:${VAULT_GROUP} /usr/local/bin/vault

logger "Granting mlock syscall to vault binary"
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault

logger "/usr/local/bin/vault --version: $(/usr/local/bin/vault --version)"

logger "Configuring vault"
sudo mkdir -pm 0755 ${CONFIG_DIR} ${SSL_DIR}

if [[ "${VAULT_TLS}" = "true" ]]; then
  logger "Configuring vault-tls"
  sudo cp /tmp/vault/config/vault-tls.hcl ${CONFIG_DIR}
else
  logger "Configuring vault-no-tls"
  sudo cp /tmp/vault/config/vault-no-tls.hcl ${CONFIG_DIR}
fi

if [[ "${VAULT_CONSUL}" = "true" ]]; then
  logger "Configuring vault/consul"
  sudo cp /tmp/vault/config/vault-consul.hcl ${CONFIG_DIR}
fi

sudo chown -R ${VAULT_USER}:${VAULT_GROUP} ${CONFIG_DIR} ${SSL_DIR}
sudo chmod -R 0644 ${CONFIG_DIR}/*

logger "Complete"
