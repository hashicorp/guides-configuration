#!/bin/bash
set -x

YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

echo "Running"

if [[ ! -z ${YUM} ]]; then
  echo "Installing Docker with RHEL Workaround"
  sudo yum -yq install policycoreutils-python yum-utils device-mapper-persistent-data lvm2
  sudo yum -y remove docker-engine-selinux container-selinux
  sudo yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo

  sudo yum install -y --setopt=obsoletes=0 \
   docker-ce \
   docker-ce-selinux
elif [[ ! -z ${APT_GET} ]]; then
  echo "Installing Docker"
  curl -sSL https://get.docker.com/ | sudo sh
else
  echo "Prerequisites not installed due to OS detection failure"
  exit 1;
fi

sudo sh -c "echo \"DOCKER_OPTS='--dns 127.0.0.1 --dns 8.8.8.8 --dns-search service.consul'\" >> /etc/default/docker"

sudo systemctl enable docker
sudo systemctl start docker

echo "Complete"
