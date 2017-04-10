#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT install-consul-template.sh: $1"
}

CONSUL_TEMPLATE_VERSION=${VERSION:-0.18.2}
CONSUL_TEMPLATE_ZIP=/tmp/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
CONSUL_TEMPLATE_URL="https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip"
CONSUL_TEMPLATE_USER=${USER:-}
CONSUL_TEMPLATE_GROUP=${GROUP:-}

cd /tmp
logger "Downloading consul-template"
wget $CONSUL_TEMPLATE_URL --quiet -O $CONSUL_TEMPLATE_ZIP

logger "Unpacking consul-template"
unzip -q $CONSUL_TEMPLATE_ZIP >/dev/null
rm -f $CONSUL_TEMPLATE_ZIP

logger "Installing consul-template"
sudo chmod +x consul-template
sudo mv consul-template /usr/local/bin
sudo chmod 0755 /usr/local/bin/consul-template
sudo chown root:root /usr/local/bin/consul-template

logger "Installed consul-template version is $(consul-template --version 2>&1)"

logger "Setup consul-template configuration directory"
sudo mkdir -pm 0600 /etc/consul-template.d /opt/consul-template
sudo chmod -R 0755 /etc/consul-template.d
sudo chown -R ${CONSUL_TEMPLATE_USER}.${CONSUL_TEMPLATE_GROUP} /etc/consul-template.d /opt/consul-template

logger "Complete"
