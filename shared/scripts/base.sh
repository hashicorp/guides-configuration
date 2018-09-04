#!/bin/bash
set -x

echo "Running"

echo "Installing jq"
sudo curl --silent -Lo /bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
sudo chmod +x /bin/jq

echo "Setting timezone to UTC"
sudo timedatectl set-timezone UTC

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z ${YUM} ]]; then
  echo "RHEL/CentOS system detected"
  echo "Performing updates and installing prerequisites"
  sudo yum-config-manager --enable rhui-REGION-rhel-server-releases-optional
  sudo yum-config-manager --enable rhui-REGION-rhel-server-supplementary
  sudo yum-config-manager --enable rhui-REGION-rhel-server-extras
  sudo yum -y check-update

  echo "Install base packages"
  sudo yum install -q -y wget unzip bind-utils ruby rubygems ntp git ca-certificates
  sudo systemctl start ntpd.service
  sudo systemctl enable ntpd.service

  echo "Add node.js yum repository"
  sudo yum install -q -y gcc-c++ make
  curl -sL https://rpm.nodesource.com/setup_6.x | sudo -E bash -

  echo "Add nginx yum repository"
  sudo wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  sudo yum install -q -y ./epel-release-latest-*.noarch.rpm

  echo "Install nodejs & nginx packages"
  sudo yum install -q -y nodejs nginx
elif [[ ! -z ${APT_GET} ]]; then
  echo "Debian/Ubuntu system detected"
  echo "Performing updates and installing prerequisites"
  sudo apt-get -qq -y update
  sudo apt-get install -qq -y wget unzip dnsutils ruby rubygems ntp git nodejs-legacy npm nginx
  sudo systemctl start ntp.service
  sudo systemctl enable ntp.service
  echo "Disable reverse dns lookup in SSH"
  sudo sh -c 'echo "\nUseDNS no" >> /etc/ssh/sshd_config'
  sudo service ssh restart
else
  echo "Prerequisites not installed due to OS detection failure"
  exit 1;
fi

echo "Complete"
