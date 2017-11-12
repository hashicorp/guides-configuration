#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT $0: $1"
}

logger "Running"

cd /tmp

logger "Cloning guides-configuration repo"
git clone https://github.com/hashicorp/guides-configuration.git

# TODO: Remove when merged
git checkout f-refactor

logger "Complete"
