#!/usr/bin/env bash
set -x

CONSUL_SNAPSHOT_USER=${USER:-}
CONSUL_SNAPSHOT_GROUP=${GROUP:-}
CONSUL_SNAPSHOT_AWS_S3=${AWS_S3:-}
cd /tmp

echo "Setup Consul Snapshot default configuration and data directories"
sudo mkdir -pm 0600 /etc/consul-snapshot.d /opt/consul-snapshot/data
sudo cp /tmp/consul/config/consul-snapshot-default.json /etc/consul-snapshot.d/consul-snapshot-default.json
sudo chmod -R 0755 /etc/consul-snapshot.d
sudo chown -R ${CONSUL_SNAPSHOT_USER}.${CONSUL_SNAPSHOT_GROUP} /etc/consul-snapshot.d /opt/consul-snapshot

if [[ ! -z ${CONSUL_SNAPSHOT_AWS_S3} ]]; then
  echo "Setup Consul Snapshot AWS S3 configuration"
  sudo cp /tmp/consul/config/consul-snapshot-aws-s3.json /etc/consul-snapshot.d/consul-snapshot-aws-s3.json
fi

echo "Complete"
