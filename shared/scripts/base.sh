#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT base.sh: $1"
}

logger "Installing jq"
sudo curl -Lo /bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
sudo chmod +x /bin/jq

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z ${YUM} ]]; then
  logger "RHEL or CentOS system detected"
  logger "Performing updates and installing prerequisites"
  sudo yum -y update
  sudo yum install -q -y wget unzip
elif [[ ! -z ${APT_GET} ]]; then
  logger "Debian or Ubuntu system detected"
  logger "Performing updates and installing prerequisites"
  sudo apt-get -qq -y update
  sudo apt-get install -qq -y wget unzip
else
  logger "OS Detection failed, prerequisites not installed."
  exit 1;
fi

logger "Disable reverse dns lookup in SSH"
sudo sh -c 'echo "UseDNS no" >> /etc/ssh/sshd_config'

logger "Complete"
