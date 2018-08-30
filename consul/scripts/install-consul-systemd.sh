#!/bin/bash
set -x

echo "Running"

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z ${YUM} ]]; then
  SYSTEMD_DIR="/etc/systemd/system"
  echo "Installing consul systemd service for RHEL/CentOS"
elif [[ ! -z ${APT_GET} ]]; then
  SYSTEMD_DIR="/lib/systemd/system"
  echo "Installing consul systemd service for Debian/Ubuntu"
else
  echo "Service not installed due to OS detection failure"
  exit 1;
fi

sudo curl --silent -Lo ${SYSTEMD_DIR}/consul.service https://raw.githubusercontent.com/hashicorp/guides-configuration/master/consul/init/systemd/consul.service
sudo chmod 0664 ${SYSTEMD_DIR}/consul.service

sudo systemctl enable consul
sudo systemctl start consul

echo "Complete"
