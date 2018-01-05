#!/usr/bin/env bash
set -x

echo "Running"

VAULT_VERSION="${VERSION}"
VAULT_ZIP="vault_${VAULT_VERSION}_linux_amd64.zip"
VAULT_URL=${URL:-"https://releases.hashicorp.com/vault/${VAULT_VERSION}/${VAULT_ZIP}"}

echo "Downloading vault ${VAULT_VERSION}"
[200 -ne $(curl --write-out %{http_code} --silent --output /tmp/${VAULT_ZIP} ${VAULT_URL})] && exit 1

echo "Installing vault"
sudo unzip -o /tmp/${VAULT_ZIP} -d /usr/local/bin/
sudo chmod 0755 /usr/local/bin/vault
sudo chown ${USER}:${GROUP} /usr/local/bin/vault
echo "/usr/local/bin/vault --version: $(/usr/local/bin/vault --version)"

echo "Configuring vault ${VAULT_VERSION}"
sudo mkdir -pm 0755 /etc/vault.d /opt/vault/data /opt/vault/tls

# Start Vault in -dev mode
echo "FLAGS=-dev -dev-root-token-id=root" | sudo tee /etc/vault.d/vault.conf

sudo chown -R ${USER}:${GROUP} /etc/vault.d /opt/vault
sudo chmod -R 0644 /etc/vault.d/*

echo "export VAULT_ADDR=http://127.0.0.1:8200" | sudo tee /etc/profile.d/vault.sh
echo "export VAULT_TOKEN=root" | sudo tee -a /etc/profile.d/vault.sh

echo "Granting mlock syscall to vault binary"
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault

echo "Complete"
