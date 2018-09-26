#!/bin/bash
set -x

echo "Running"

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z ${YUM} ]]; then
  echo "RHEL/CentOS system detected"
  echo "Disabling firewall"
  sudo systemctl stop firewalld.service
  sudo systemctl disable firewalld.service
elif [[ ! -z ${APT_GET} ]]; then
  echo "Debian/Ubuntu system detected"
  echo "Disabling firewall"
  sudo ufw disable
else
  echo "Prerequisites not installed due to OS detection failure"
  exit 1;
fi

echo "Complete"
