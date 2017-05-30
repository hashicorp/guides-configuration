#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT $0: $1"
}

logger "Running"

logger "Cleanup install artifacts"
sudo rm -rf /tmp/*

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z ${YUM} ]]; then
  logger "RHEL/CentOS system detected"
  logger "Performing cleanup"
  history -cw
elif [[ ! -z ${APT_GET} ]]; then
  logger "Debian/Ubuntu system detected"
  logger "Performing cleanup"
  history -c
else
  logger "Cleanup aborted due to OS detection failure"
  exit 1;
fi

logger "Complete"
