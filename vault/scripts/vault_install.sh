#!/usr/bin/env bash

VAULT=0.6.5
VAULT_URL=${1:-https://releases.hashicorp.com/vault/${VAULT}/vault_${VAULT}_linux_amd64.zip}
VAULT_ZIP=/tmp/vault_${VAULT}_linux_amd64.zip
VAULT_USER="vault"
VAULT_COMMENT="Vault Server"
VAULT_GROUP="vault"
VAULT_HOME="/srv/vault"
# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

# Download Vault from releases.hashicorp.com
cd /tmp
echo "Downloading Vault"
curl -L -o $VAULT_ZIP $VAULT_URL

echo "Unpacking Vault"
unzip -p $VAULT_ZIP > vault.bin
rm -f $VAULT_ZIP

echo "Installing Vault"
sudo chmod +x vault.bin
sudo mv vault.bin /usr/local/bin/vault
sudo chmod 0755 /usr/local/bin/vault
sudo chown root:root /usr/local/bin/vault

echo "Granting mlock syscall to Vault binary"
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault

echo "Installed Vault version is $(/usr/local/bin/vault --version)"

vault_user_rhel() {
  # RHEL user setup
  sudo /usr/sbin/groupadd --force --system ${VAULT_GROUP}

  if ! getent passwd vault >/dev/null ; then
          sudo /usr/sbin/adduser \
            --system \
            --gid ${VAULT_GROUP} \
            --home ${VAULT_HOME} \
            --no-create-home \
            --comment "${VAULT_COMMENT}" \
            --shell /bin/false \
            $VAULT_USER  >/dev/null
  fi
}

vault_user_ubuntu() {
  # UBUNTU user setup
  if ! getent group $VAULT_GROUP >/dev/null
  then
    sudo addgroup --system $VAULT_GROUP >/dev/null
  fi

  if ! getent passwd $VAULT_USER >/dev/null
  then
          sudo adduser \
            --system \
            --disabled-login \
            --ingroup ${VAULT_GROUP} \
            --home ${VAULT_HOME} \
            --no-create-home \
            --gecos "${VAULT_COMMENT}" \
            --shell /bin/false \
            $VAULT_USER  >/dev/null
  fi
}

if [[ ! -z ${YUM} ]]; then
  echo "Setting up Vault user - type RHEL"
  vault_user_rhel
elif [[ ! -z ${APT_GET} ]]; then
  echo "Setting up Vault user - type Ubuntu"
  vault_user_ubuntu
else
  echo "OS Detection failed, vault user not created."
  exit 1;
fi

echo "Setup Vault configuration directory and ssl directory"
sudo mkdir -pm 0600 /etc/vault /etc/ssl/vault/
sudo cp /tmp/vault/files/config.hcl /etc/vault/config.hcl
sudo chown -R vault.vault /etc/vault /etc/ssl/vault/
