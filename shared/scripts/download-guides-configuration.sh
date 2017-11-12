#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT $0: $1"
}

logger "Running"

cd /tmp

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

logger "Installing git"
if [[ ! -z ${YUM} ]]; then
  logger "RHEL/CentOS system detected"
  logger "Performing updates and installing prerequisites"
  sudo yum -y check-update
  sudo yum install -q -y git
elif [[ ! -z ${APT_GET} ]]; then
  logger "Debian/Ubuntu system detected"
  logger "Performing updates and installing prerequisites"
  sudo apt-get -qq -y update
  sudo apt-get install -qq -y git
else
  logger "Prerequisites not installed due to OS detection failure"
  exit 1;
fi

logger "Cloning guides-configuration repo"
git clone https://github.com/hashicorp/guides-configuration.git

# TODO: Remove when merged
cd guides-configuration
git checkout f-refactor

logger "Complete"
