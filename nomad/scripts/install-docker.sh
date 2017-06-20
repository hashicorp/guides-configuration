#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT docker.sh: $1"
}

logger "Executing"

USER=$1

logger "Installing Docker"

curl -sSL https://get.docker.com/ | sudo sh
sudo sh -c "echo \"DOCKER_OPTS='--dns 127.0.0.1 --dns 8.8.8.8 --dns-search service.consul'\" >> /etc/default/docker"
sudo usermod -aG docker $USER

service docker restart

logger "Completed"
