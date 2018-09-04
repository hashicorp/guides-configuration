#!/bin/bash
set -x

echo "Running"

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z ${YUM} ]]; then
  SYSTEMD_DIR="/etc/systemd/system"
  echo "Installing systemd services for RHEL/CentOS"
elif [[ ! -z ${APT_GET} ]]; then
  SYSTEMD_DIR="/lib/systemd/system"
  echo "Installing systemd services for Debian/Ubuntu"
else
  echo "Service not installed due to OS detection failure"
  exit 1;
fi

sudo curl --silent -Lo ${SYSTEMD_DIR}/vault.service https://raw.githubusercontent.com/hashicorp/guides-configuration/master/vault/init/systemd/vault.service
sudo curl --silent -Lo ${SYSTEMD_DIR}/consul-online.service https://raw.githubusercontent.com/hashicorp/guides-configuration/master/consul/init/systemd/consul-online.service
sudo curl --silent -Lo ${SYSTEMD_DIR}/consul-online.target https://raw.githubusercontent.com/hashicorp/guides-configuration/master/consul/init/systemd/consul-online.target
sudo curl --silent -Lo ${SYSTEMD_DIR}/consul-online.sh https://raw.githubusercontent.com/hashicorp/guides-configuration/master/consul/init/systemd/consul-online.sh
sudo chmod 0664 ${SYSTEMD_DIR}/{vault*,consul*}

sudo systemctl enable consul
sudo systemctl start consul

sudo systemctl enable vault
sudo systemctl start vault

echo "Complete"
