#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT $0: $1"
}

logger "Running"

NOMAD_VERSION="${VERSION}"
NOMAD_ZIP="nomad_${NOMAD_VERSION}_linux_amd64.zip"
NOMAD_URL=${URL:-"https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/${NOMAD_ZIP}"}

logger "Downloading nomad ${NOMAD_VERSION}"
[200 -ne $(curl --write-out %{http_code} --silent --output /tmp/${NOMAD_ZIP} ${NOMAD_URL})] && exit 1

logger "Installing nomad"
sudo unzip -o /tmp/${NOMAD_ZIP} -d /usr/local/bin/
sudo chmod 0755 /usr/local/bin/nomad
sudo chown ${USER}:${GROUP} /usr/local/bin/nomad
logger "/usr/local/bin/nomad --version: $(/usr/local/bin/nomad --version)"

logger "Configuring nomad ${NOMAD_VERSION}"
sudo mkdir -pm 0755 /etc/nomad.d
sudo mkdir -pm 0755 /opt/nomad/data
sudo chmod -R 0755 /opt/nomad/*

# Copy over all example Nomad config files
sudo cp /tmp/nomad/config/* /etc/nomad.d/.

# Start Nomad in -dev mode
echo 'FLAGS=-dev' | sudo tee /etc/nomad.d/nomad.conf

sudo chown -R ${USER}:${GROUP} /etc/nomad.d /opt/nomad
sudo chmod -R 0644 /etc/nomad.d/*

logger "Complete"
