#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT cleanup.sh: $1"
}

logger "Cleanup install artifacts"
sudo rm -rf /tmp/*

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z ${YUM} ]]; then
  logger "RHEL or CentOS system detected"
  logger "Performing cleanup"
  history -cw
elif [[ ! -z ${APT_GET} ]]; then
  logger "Debian or Ubuntu system detected"
  logger "No cleanup necessary"
else
  logger "OS Detection failed, prerequisites not installed."
  exit 1;
fi

logger "Complete"
