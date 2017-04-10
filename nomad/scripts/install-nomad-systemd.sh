#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT install-nomad-systemd.sh: $1"
}

logger "Installing Nomad systemd services"
sudo cp /tmp/nomad/init/systemd/nomad.service /etc/systemd/system/nomad.service
sudo cp /tmp/consul/init/systemd/consul.service /etc/systemd/system/consul.service
sudo cp /tmp/consul/init/systemd/consul-online.service /etc/systemd/system/consul-online.service
sudo cp /tmp/consul/init/systemd/consul-online.target /etc/systemd/system/consul-online.target
sudo cp /tmp/consul/init/systemd/consul-online.sh /usr/bin/consul-online.sh

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z ${YUM} ]]; then
  logger "Installing systemd services for RHEL/CentOS"
  sudo chmod 664 /etc/systemd/system/{nomad.*,consul.*}
elif [[ ! -z ${APT_GET} ]]; then
  logger "Installing systemd services for Ubuntu/Debian"
  sudo chmod 664 /lib/systemd/system/nomad*
  sudo chmod 664 /lib/systemd/system/consul*
else
  logger "OS Detection failed, ${USER} user not created."
  exit 1;
fi

logger "Complete"
