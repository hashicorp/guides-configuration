#!/usr/bin/env bash
set -x

CONSUL_TEMPLATE_VERSION=${VERSION:-0.18.1}
CONSUL_TEMPLATE_ZIP=/tmp/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
CONSUL_TEMPLATE_URL="https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip"

cd /tmp
echo "Downloading Consul Template"
wget $CONSUL_TEMPLATE_URL --quiet -O $CONSUL_TEMPLATE_ZIP

echo "Unpacking Consul Template"
unzip -q $CONSUL_TEMPLATE_ZIP >/dev/null
rm -f $CONSUL_TEMPLATE_ZIP

echo "Installing Consul Template"
sudo chmod +x consul-template
sudo mv consul-template /usr/local/bin
sudo chmod 0755 /usr/local/bin/consul-template
sudo chown root:root /usr/local/bin/consul-template

echo "Installed Consul Template version is $(consul-template --version 2>&1)"
