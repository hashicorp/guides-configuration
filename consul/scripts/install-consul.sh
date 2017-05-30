#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT $0: $1"
}

logger "Running"

CONSUL_VERSION="${VERSION}"
CONSUL_ZIP="consul_${CONSUL_VERSION}_linux_amd64.zip"
CONSUL_URL=${URL:-"https://releases.hashicorp.com/consul/${CONSUL_VERSION}/${CONSUL_ZIP}"}
CONSUL_USER="consul"
CONSUL_GROUP="consul"
CONFIG_DIR="/etc/consul.d"
DATA_DIR="/opt/consul/data"
DOWNLOAD_DIR="/tmp"

logger "Downloading consul ${CONSUL_VERSION}"
curl --silent --output ${DOWNLOAD_DIR}/${CONSUL_ZIP} ${CONSUL_URL}

logger "Installing consul"
sudo unzip -o ${DOWNLOAD_DIR}/${CONSUL_ZIP} -d /usr/local/bin/
sudo chmod 0755 /usr/local/bin/consul
sudo chown ${CONSUL_USER}:${CONSUL_GROUP} /usr/local/bin/consul
sudo mkdir -pm 0755 ${CONFIG_DIR} ${DATA_DIR}
sudo cp /tmp/consul/config/*.example ${CONFIG_DIR}
sudo chown -R ${CONSUL_USER}:${CONSUL_GROUP} ${CONFIG_DIR} ${DATA_DIR}
sudo chmod -R 0644 ${CONFIG_DIR}/*

logger "/usr/local/bin/consul --version: $(/usr/local/bin/consul --version)"

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z ${YUM} ]]; then
  logger "Installing dnsmasq"
  sudo yum install -q -y dnsmasq
elif [[ ! -z ${APT_GET} ]]; then
  logger "Installing dnsmasq"
  sudo apt-get -qq -y update
  sudo apt-get install -qq -y dnsmasq-base dnsmasq
else
  logger "Dnsmasq not installed due to OS detection failure"
  exit 1;
fi

logger "Configuring dnsmasq to forward .consul requests to consul port 8600"
sudo sh -c 'echo "server=/consul/127.0.0.1#8600" >> /etc/dnsmasq.d/consul'
sudo sh -c 'echo "listen-address=127.0.0.1" >> /etc/dnsmasq.d/consul'
sudo sh -c 'echo "bind-interfaces" >> /etc/dnsmasq.d/consul'
sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq

logger "Complete"
