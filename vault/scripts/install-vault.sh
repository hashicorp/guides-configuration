#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT vault-install.sh: $1"
}

VAULT_VERSION=${VERSION:-0.7.0}
VAULT_URL=${VAULT_ENT:-https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip}
VAULT_ZIP=/tmp/vault_${VAULT_VERSION}_linux_amd64.zip
VAULT_USER=${USER:-}
VAULT_GROUP=${GROUP:-}

cd /tmp
logger "Downloading Vault"
curl -L -o $VAULT_ZIP $VAULT_URL

logger "Unpacking Vault"
unzip -p $VAULT_ZIP > vault.bin
rm -f $VAULT_ZIP

logger "Installing Vault"
sudo chmod +x vault.bin
sudo mv vault.bin /usr/local/bin/vault
sudo chmod 0755 /usr/local/bin/vault
sudo chown root:root /usr/local/bin/vault

logger "Granting mlock syscall to Vault binary"
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault

logger "Installed Vault version is $(/usr/local/bin/vault --version)"

logger "Setup Vault configuration directory and ssl directory"
sudo mkdir -pm 0600 /etc/vault.d /etc/ssl/vault/
sudo cp /tmp/vault/config/consul-backend.hcl /etc/vault.d/consul-backend.hcl
sudo chmod -R 0755 /etc/vault.d
sudo chown -R ${VAULT_USER}.${VAULT_GROUP} /etc/vault.d /etc/ssl/vault/

logger "Complete"
