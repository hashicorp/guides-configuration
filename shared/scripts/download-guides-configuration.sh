#!/usr/bin/env bash
set -x

echo "Running"

cd /tmp

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

echo "Installing git"
if [[ ! -z ${YUM} ]]; then
  echo "RHEL/CentOS system detected"
  sudo yum -y check-update
  sudo yum install -q -y git
elif [[ ! -z ${APT_GET} ]]; then
  echo "Debian/Ubuntu system detected"
  sudo apt-get -qq -y update
  sudo apt-get install -qq -y git
else
  echo "Prerequisites not installed due to OS detection failure"
  exit 1;
fi

echo "Cloning guides-configuration repo"
git clone https://github.com/hashicorp/guides-configuration.git
cp -a guides-configuration/. .
rm -rf guides-configuration

# TODO: Remove when merged
git checkout f-refactor

echo "Complete"
