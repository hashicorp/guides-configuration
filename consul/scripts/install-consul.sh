#!/usr/bin/env bash
set -x

echo "Running"

CONSUL_VERSION="${VERSION}"
CONSUL_ZIP="consul_${CONSUL_VERSION}_linux_amd64.zip"
CONSUL_URL=${URL:-https://releases.hashicorp.com/consul/${CONSUL_VERSION}/${CONSUL_ZIP}}
CONSUL_DIR=/usr/local/bin
CONSUL_PATH=${CONSUL_DIR}/consul
CONSUL_CONFIG_DIR=/etc/consul.d
CONSUL_DATA_DIR=/opt/consul/data
CONSUL_TLS_DIR=/opt/consul/tls
CONSUL_ENV_VARS=${CONSUL_CONFIG_DIR}/consul.conf
CONSUL_PROFILE_SCRIPT=/etc/profile.d/consul.sh

echo "Downloading Consul ${CONSUL_VERSION}"
[ 200 -ne $(curl --write-out %{http_code} --silent --output /tmp/${CONSUL_ZIP} ${CONSUL_URL}) ] && exit 1

echo "Installing Consul"
sudo unzip -o /tmp/${CONSUL_ZIP} -d ${CONSUL_DIR}
sudo chmod 0755 ${CONSUL_PATH}
sudo chown ${USER}:${GROUP} ${CONSUL_PATH}
echo "$(${CONSUL_PATH} --version)"

echo "Configuring Consul ${CONSUL_VERSION}"
sudo mkdir -pm 0755 ${CONSUL_CONFIG_DIR} ${CONSUL_DATA_DIR} ${CONSUL_TLS_DIR}

echo "Start Consul in -dev mode"
cat <<ENVVARS | sudo tee ${CONSUL_ENV_VARS}
FLAGS=-dev -ui
ENVVARS

echo "Update directory permissions"
sudo chown -R ${USER}:${GROUP} ${CONSUL_CONFIG_DIR} ${CONSUL_DATA_DIR} ${CONSUL_TLS_DIR}
sudo chmod -R 0644 ${CONSUL_CONFIG_DIR}/*

echo "Set Consul profile script"
cat <<PROFILE | sudo tee ${CONSUL_PROFILE_SCRIPT}
export CONSUL_HTTP_ADDR=http://127.0.0.1:8500
PROFILE

echo "Detect package management system."
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z ${YUM} ]]; then
  echo "Installing dnsmasq via yum"
  sudo yum install -q -y dnsmasq
  sudo sed -i '1i nameserver 127.0.0.1\n' /etc/resolv.conf
elif [[ ! -z ${APT_GET} ]]; then
  echo "Installing dnsmasq via apt-get"
  sudo apt-get -qq -y update
  sudo apt-get install -qq -y dnsmasq-base dnsmasq
else
  echo "Dnsmasq not installed due to OS detection failure"
  exit 1;
fi

echo "Configuring dnsmasq to forward .consul requests to consul port 8600"
cat <<DNSMASQ | sudo tee /etc/dnsmasq.d/consul
server=/consul/127.0.0.1#8600
DNSMASQ

echo "Enable and rsetart dnsmasq"
sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq

echo "Complete"
