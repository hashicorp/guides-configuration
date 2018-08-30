#!/bin/bash
set -x

echo "Running"

echo "Cleanup install artifacts"
sudo rm -rf /tmp/*

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z ${YUM} ]]; then
  echo "RHEL/CentOS system detected"
  echo "Performing cleanup"
  history -cw
elif [[ ! -z ${APT_GET} ]]; then
  echo "Debian/Ubuntu system detected"
  echo "Performing cleanup"
  history -c
else
  echo "Cleanup aborted due to OS detection failure"
  exit 1;
fi

echo "Complete"
