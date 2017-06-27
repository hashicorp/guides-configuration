#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT $0: $1"
}

logger "Running"

logger "Installing jq"
sudo curl --silent -Lo /bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
sudo chmod +x /bin/jq

logger "Setting timezone to UTC"
sudo timedatectl set-timezone UTC

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z ${YUM} ]]; then
  logger "RHEL/CentOS system detected"
  logger "Performing updates and installing prerequisites"
  sudo yum -y check-update
  sudo yum install -q -y wget unzip bind-utils ruby rubygems ntp
  sudo systemctl start ntp.service
  sudo systemctl enable ntp.service
elif [[ ! -z ${APT_GET} ]]; then
  logger "Debian/Ubuntu system detected"
  logger "Performing updates and installing prerequisites"
  sudo apt-get -qq -y update
  sudo apt-get install -qq -y wget unzip dnsutils ruby rubygems ntp
  sudo systemctl start ntp.service
  sudo systemctl enable ntp.service
else
  logger "Prerequisites not installed due to OS detection failure"
  exit 1;
fi

logger "Disable reverse dns lookup in SSH"
sudo sh -c 'echo "UseDNS no" >> /etc/ssh/sshd_config'

logger "Complete"
