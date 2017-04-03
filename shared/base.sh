#!/usr/bin/env bash
set -x

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

echo "Installing jq"
sudo curl -Lo /bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
sudo chmod +x /bin/jq

if [[ ! -z ${YUM} ]]; then
  echo "RHEL or CentOS system detected"
  echo "Performing updates and installing prerequisites"
  sudo yum -y update
  sudo yum install -q -y wget unzip
  curl -O https://bootstrap.pypa.io/get-pip.py
  sudo python get-pip.py
  sudo pip install awscli
elif [[ ! -z ${APT_GET} ]]; then
  echo "Debian or Ubuntu system detected"
  echo "Performing updates and installing prerequisites"
  sudo apt-get -qq -y update
  sudo apt-get install -qq -y wget unzip awscli
else
  echo "OS Detection failed, prerequisites not installed."
  exit 1;
fi

echo "Disable reverse dns lookup in SSH"
sudo sh -c 'echo "UseDNS no" >> /etc/ssh/sshd_config'
