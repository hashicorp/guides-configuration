#!/usr/bin/env bash

set -x

NOMAD_VERSION=0.5.5
NOMAD_URL=${1:-https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip}
NOMAD_ZIP=/tmp/nomad_${NOMAD_VERSION}_linux_amd64.zip
NOMAD_USER="nomad"
NOMAD_COMMENT="Nomad Server"
NOMAD_GROUP="nomad"
NOMAD_HOME="/srv/nomad"
NOMAD_TEMPLATE_ZIP=/tmp/nomad-template_${NOMAD_TEMPLATE_VERSION}_linux_amd64.zip
NOMAD_TEMPLATE_URL="https://releases.hashicorp.com/nomad-template/${NOMAD_TEMPLATE_VERSION}/nomad-template_${NOMAD_TEMPLATE_VERSION}_linux_amd64.zip"

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

cd /tmp
echo "Downloading Nomad"
curl -L -o $NOMAD_ZIP $NOMAD_URL

echo "Unpacking Nomad"
unzip -p $NOMAD_ZIP > nomad.bin
rm -f $NOMAD_ZIP

echo "Installing Nomad"
sudo chmod +x nomad.bin
sudo mv nomad.bin /usr/local/bin/nomad
sudo chmod 0755 /usr/local/bin/nomad
sudo chown root:root /usr/local/bin/nomad

echo "Installed Nomad version is $(nomad --version)"

nomad_user_rhel() {
  # RHEL user setup
  sudo /usr/sbin/groupadd --force --system ${NOMAD_GROUP}

  if ! getent passwd nomad >/dev/null ; then
    sudo /usr/sbin/adduser \
      --system \
      --gid ${NOMAD_GROUP} \
      --home ${NOMAD_HOME} \
      --no-create-home \
      --comment "${NOMAD_COMMENT}" \
      --shell /bin/false \
      $NOMAD_USER  >/dev/null
  fi
}

nomad_user_ubuntu() {
  # UBUNTU user setup
  if ! getent group $NOMAD_GROUP >/dev/null
  then
    sudo addgroup --system $NOMAD_GROUP >/dev/null
  fi

  if ! getent passwd $NOMAD_USER >/dev/null
  then
    sudo adduser \
      --system \
      --disabled-login \
      --ingroup ${NOMAD_GROUP} \
      --home ${NOMAD_HOME} \
      --no-create-home \
      --gecos "${NOMAD_COMMENT}" \
      --shell /bin/false \
      $NOMAD_USER  >/dev/null
  fi
}

if [[ ! -z ${YUM} ]]; then
  echo "Setting up Nomad user - type RHEL"
  nomad_user_rhel
elif [[ ! -z ${APT_GET} ]]; then
  echo "Setting up Nomad user - type Ubuntu"
  nomad_user_ubuntu
else
  echo "OS Detection failed, nomad user not created."
  exit 1;
fi

echo "Setup Nomad configuration and data directories"
sudo mkdir -pm 0600 /etc/nomad.d /opt/nomad/data
sudo cp /tmp/nomad/files/server.hcl /etc/nomad.d/server.hcl
sudo chown -R nomad.nomad /opt/nomad /etc/nomad.d
