#!/usr/bin/env bash
set -x

echo "Running"

CONSUL_VERSION="${VERSION}"
CONSUL_ZIP="consul_${CONSUL_VERSION}_linux_amd64.zip"
CONSUL_URL=${URL:-"https://releases.hashicorp.com/consul/${CONSUL_VERSION}/${CONSUL_ZIP}"}

echo "Downloading consul ${CONSUL_VERSION}"
[ 200 -ne $(curl --write-out %{http_code} --silent --output /tmp/${CONSUL_ZIP} ${CONSUL_URL}) ] && exit 1

echo "Installing consul"
sudo unzip -o /tmp/${CONSUL_ZIP} -d /usr/local/bin/
sudo chmod 0755 /usr/local/bin/consul
sudo chown ${USER}:${GROUP} /usr/local/bin/consul
echo "/usr/local/bin/consul --version: $(/usr/local/bin/consul --version)"

echo "Configuring consul ${CONSUL_VERSION}"
sudo mkdir -pm 0755 /etc/consul.d /opt/consul/data /opt/consul/tls

# Start Consul in -dev mode
echo "FLAGS=-dev -ui" | sudo tee /etc/consul.d/consul.conf

sudo chown -R ${USER}:${GROUP} /etc/consul.d /opt/consul/data /opt/consul/tls
sudo chmod -R 0644 /etc/consul.d/*

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z ${YUM} ]]; then
  echo "Installing dnsmasq"
  sudo yum install -q -y dnsmasq
  sudo sed -i '1i nameserver 127.0.0.1\n' /etc/resolv.conf
elif [[ ! -z ${APT_GET} ]]; then
  echo "Installing dnsmasq"
  sudo apt-get -qq -y update
  sudo apt-get install -qq -y dnsmasq-base dnsmasq
else
  echo "Dnsmasq not installed due to OS detection failure"
  exit 1;
fi

echo "Configuring dnsmasq to forward .consul requests to consul port 8600"
sudo sh -c 'echo "server=/consul/127.0.0.1#8600" > /etc/dnsmasq.d/consul'
sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq

echo "Complete"
