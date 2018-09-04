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

sudo curl --silent -Lo ${SYSTEMD_DIR}/nomad.service https://raw.githubusercontent.com/hashicorp/guides-configuration/master/nomad/init/systemd/nomad.service
sudo curl --silent -Lo ${SYSTEMD_DIR}/consul-online.service https://raw.githubusercontent.com/hashicorp/guides-configuration/master/consul/init/systemd/consul-online.service
sudo curl --silent -Lo ${SYSTEMD_DIR}/consul-online.target https://raw.githubusercontent.com/hashicorp/guides-configuration/master/consul/init/systemd/consul-online.target
sudo curl --silent -Lo ${SYSTEMD_DIR}/consul-online.sh https://raw.githubusercontent.com/hashicorp/guides-configuration/master/consul/init/systemd/consul-online.sh
sudo chmod 0664 ${SYSTEMD_DIR}/{nomad*,consul*}

sudo systemctl enable nomad
sudo systemctl start nomad

echo "Complete"
