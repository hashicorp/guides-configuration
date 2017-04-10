#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT consul-install.sh: $1"
}

CONSUL_VERSION=${VERSION:-0.8.0}
CONSUL_URL=${URL:-https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip}
CONSUL_ZIP=/tmp/consul_${CONSUL_VERSION}_linux_amd64.zip
CONSUL_SERVER=${SERVER:-}
CONSUL_USER=${USER:-}
CONSUL_GROUP=${GROUP:-}
cd /tmp

logger "Downloading Consul"
curl -L -o $CONSUL_ZIP $CONSUL_URL

logger "Unpacking Consul"
unzip -p $CONSUL_ZIP > consul.bin
rm -f $CONSUL_ZIP

logger "Installing Consul"
sudo chmod +x consul.bin
sudo mv consul.bin /usr/local/bin/consul
sudo chmod 0755 /usr/local/bin/consul
sudo chown root:root /usr/local/bin/consul

logger "Installed Consul version is $(/usr/local/bin/consul --version)"

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

logger "Installing dnsmasq"
if [[ ! -z ${YUM} ]]; then
  sudo yum install -q -y dnsmasq
elif [[ ! -z ${APT_GET} ]]; then
  sudo apt-get -qq -y update
  sudo apt-get install -qq -y dnsmasq-base dnsmasq
else
  logger "OS Detection failed, Dnsmasq not installed."
  exit 1;
fi

logger "Configuring dnsmasq to forward .consul requests to Consul port 8600"
sudo sh -c 'echo "server=/consul/127.0.0.1#8600" >> /etc/dnsmasq.d/consul'
sudo sh -c 'echo "listen-address=127.0.0.1" >> /etc/dnsmasq.d/consul'
sudo sh -c 'echo "bind-interfaces" >> /etc/dnsmasq.d/consul'
sudo service dnsmasq restart

logger "Setup Consul default configuration and data directories"
sudo mkdir -pm 0600 /etc/consul.d /opt/consul/data
sudo cp /tmp/consul/config/consul-default.json /etc/consul.d/consul-default.json
sudo chown -R ${CONSUL_USER}.${CONSUL_GROUP} /etc/consul.d /opt/consul
sudo chmod -R 0755 /etc/consul.d

if [[ ! -z ${CONSUL_SERVER} ]]; then
  logger "Setup Consul server configuration"
  sudo cp /tmp/consul/config/consul-server.json /etc/consul.d/consul-server.json
fi

logger "Complete"
