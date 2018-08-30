#!/bin/bash
set -x

echo "Running"

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z ${YUM} ]]; then
  echo "RHEL/CentOS system detected"
  echo "Performing updates and installing prerequisites"
  sudo yum check-update
  sudo yum install -q -y gcc libffi-devel python-devel openssl-devel python-pip
  sudo pip install azure-cli
elif [[ ! -z ${APT_GET} ]]; then
  echo "Debian/Ubuntu system detected"
  echo "Performing updates and installing prerequisites"
  sudo apt-get -qq -y update
  sudo apt-get install -qq -y libssl-dev libffi-dev python-dev build-essential python-pip
  sudo pip install azure-cli
else
  echo "Prerequisites not installed due to OS detection failure"
  exit 1;
fi

echo "Complete"
