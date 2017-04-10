#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT vault-si-install.sh: $1"
}

VAULT_SI_URL=${VAULT_SI_ENT}
VAULT_SI_ZIP=/tmp/vault-si_${VAULT_SI_VERSION}_linux_amd64.zip
VAULT_SI_USER=${USER:-}
VAULT_SI_GROUP=${GROUP:-}

cd /tmp
logger "Downloading Vault SI"
curl -L -o $VAULT_SI_ZIP $VAULT_SI_URL

logger "Unpacking Vault SI"
unzip -p $VAULT_SI_ZIP > vault-si.bin
rm -f $VAULT_SI_ZIP

logger "Installing Vault SI"
sudo chmod +x vault-si.bin
sudo mv vault-si.bin /usr/local/bin/vault-si
sudo chmod 0755 /usr/local/bin/vault-si
sudo chown root:root /usr/local/bin/vault-si

logger "Installed Vault SI version is $(/usr/local/bin/vault-si --version)"

logger "Setup Vault configuration directory"
sudo mkdir -pm 0600 /etc/vault-si.d
sudo cp /tmp/vault-si/config/vault-si.hcl /etc/vault-si.d/vault-si.hcl
sudo chmod -R 0755 /etc/vault-si.d
sudo chown -R ${VAULT_SI_USER}.${VAULT_SI_GROUP} /etc/vault-si.d

logger "Complete"
