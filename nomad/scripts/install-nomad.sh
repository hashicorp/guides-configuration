#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT nomad-install.sh: $1"
}

NOMAD_VERSION=${VERSION:-0.5.6}
NOMAD_URL=${1:-https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip}
NOMAD_ZIP=/tmp/nomad_${NOMAD_VERSION}_linux_amd64.zip
NOMAD_USER=${USER:-}
NOMAD_GROUP=${GROUP:-}
NOMAD_CLIENT=${CLIENT}
NOMAD_SERVER=${SERVER}
NOMAD_CONSUL=${CONSUL}

cd /tmp
logger "Downloading Nomad"
curl -L -o $NOMAD_ZIP $NOMAD_URL

logger "Unpacking Nomad"
unzip -p $NOMAD_ZIP > nomad.bin
rm -f $NOMAD_ZIP

logger "Installing Nomad"
sudo chmod +x nomad.bin
sudo mv nomad.bin /usr/local/bin/nomad
sudo chmod 0755 /usr/local/bin/nomad
sudo chown root:root /usr/local/bin/nomad

logger "Installed Nomad version is $(/usr/local/bin/nomad --version)"

logger "Setup Nomad configuration and data directories"
sudo mkdir -pm 0600 /etc/nomad.d /opt/nomad/data
sudo cp /tmp/nomad/config/nomad-default.hcl /etc/nomad.d/nomad-default.hcl
sudo cp /tmp/nomad/config/nomad-consul.hcl /etc/nomad.d/nomad-consul.hcl
sudo chmod -R 0755 /etc/nomad.d
sudo chown -R ${NOMAD_USER}.${NOMAD_GROUP} /opt/nomad /etc/nomad.d

if [[ ! -z ${NOMAD_CLIENT} ]]; then
  logger "Setup Nomad client configuration"
  sudo cp /tmp/nomad/config/nomad-client.hcl /etc/nomad.d/nomad-client.hcl
fi

if [[ ! -z ${NOMAD_SERVER} ]]; then
  logger "Setup Nomad server configuration"
  sudo cp /tmp/nomad/config/nomad-server.hcl /etc/nomad.d/nomad-server.hcl
fi

if [[ ! -z ${NOMAD_CONSUL} ]]; then
  logger "Setup Nomad Consul configuration"
  sudo cp /tmp/nomad/config/nomad-consul.hcl /etc/nomad.d/nomad-consul.hcl
fi

logger "Complete"
