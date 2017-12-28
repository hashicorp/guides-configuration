#!/usr/bin/env bash
set -x

echo "Running"

echo "Reset HashiCorp services"
[[ -f "/usr/local/bin/consul" ]] && sudo systemctl stop consul && sudo rm -rf /opt/consul/data/*
[[ -f "/usr/local/bin/nomad" ]] && sudo systemctl stop nomad && sudo rm -rf /opt/nomad/data/*
[[ -f "/usr/local/bin/vault" ]] && sudo systemctl stop vault && sudo rm -rf /opt/vault/data/*

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
