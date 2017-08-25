#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT $0: $1"
}

logger "Running"

logger "Cleanup & deprovision to create generalized image"

sudo apt-get update -qq -y
sudo apt-get upgrade -qq -y
sudo -E sh "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"

logger "Complete"