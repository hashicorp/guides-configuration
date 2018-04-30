#!/usr/bin/env bash
set -x

echo "Running"

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z ${YUM} ]]; then
  SYSTEMD_DIR="/etc/systemd/system"
  echo "Installing systemd services for RHEL/CentOS"
  sudo cp /tmp/nomad/init/systemd/nomad.service ${SYSTEMD_DIR}
  sudo cp /tmp/consul/init/systemd/consul-online.service ${SYSTEMD_DIR}
  sudo cp /tmp/consul/init/systemd/consul-online.target ${SYSTEMD_DIR}
  sudo cp /tmp/consul/init/systemd/consul-online.sh /usr/bin/consul-online.sh
  sudo chmod 0664 ${SYSTEMD_DIR}/{nomad*,consul*}
elif [[ ! -z ${APT_GET} ]]; then
  SYSTEMD_DIR="/lib/systemd/system"
  echo "Installing systemd services for Debian/Ubuntu"
  sudo cp /tmp/nomad/init/systemd/nomad.service ${SYSTEMD_DIR}
  sudo cp /tmp/consul/init/systemd/consul-online.service ${SYSTEMD_DIR}
  sudo cp /tmp/consul/init/systemd/consul-online.target ${SYSTEMD_DIR}
  sudo cp /tmp/consul/init/systemd/consul-online.sh /usr/bin/consul-online.sh
  sudo chmod 0664 ${SYSTEMD_DIR}/{nomad*,consul*}
else
  echo "Service not installed due to OS detection failure"
  exit 1;
fi

sudo systemctl enable consul
sudo systemctl start consul

sudo systemctl enable nomad
sudo systemctl start nomad

echo "Complete"
