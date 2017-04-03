#!/usr/bin/env bash
set -x

CONSUL_VERSION=${VERSION:-0.7.5}
CONSUL_URL=${URL:-https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip}
CONSUL_ZIP=/tmp/consul_${CONSUL_VERSION}_linux_amd64.zip
CONSUL_USER="consul"
CONSUL_COMMENT="Consul Server"
CONSUL_GROUP="consul"
CONSUL_HOME="/srv/consul"

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

cd /tmp
echo "Downloading Consul"
curl -L -o $CONSUL_ZIP $CONSUL_URL

echo "Unpacking Consul"
unzip -p $CONSUL_ZIP > consul.bin
rm -f $CONSUL_ZIP

echo "Installing Consul"
sudo chmod +x consul.bin
sudo mv consul.bin /usr/local/bin/consul
sudo chmod 0755 /usr/local/bin/consul
sudo chown root:root /usr/local/bin/consul

echo "Installed Consul version is $(/usr/local/bin/consul --version)"

echo "Installing dnsmasq"
if [[ ! -z ${YUM} ]]; then
  sudo yum install -q -y dnsmasq
elif [[ ! -z ${APT_GET} ]]; then
  sudo apt-get -qq -y update
  sudo apt-get install -qq -y dnsmasq-base dnsmasq
else
  echo "OS Detection failed, Dnsmasq not installed."
  exit 1;
fi

echo "Configuring dnsmasq to forward .consul requests to Consul port 8600"
sudo sh -c 'echo "server=/consul/127.0.0.1#8600" >> /etc/dnsmasq.d/consul'
sudo sh -c 'echo "listen-address=127.0.0.1" >> /etc/dnsmasq.d/consul'
sudo sh -c 'echo "bind-interfaces" >> /etc/dnsmasq.d/consul'
sudo service dnsmasq restart


consul_user_rhel() {
  # RHEL user setup
  sudo /usr/sbin/groupadd --force --system ${CONSUL_GROUP}

  if ! getent passwd consul >/dev/null ; then
    sudo /usr/sbin/adduser \
      --system \
      --gid ${CONSUL_GROUP} \
      --home ${CONSUL_HOME} \
      --no-create-home \
      --comment "${CONSUL_COMMENT}" \
      --shell /bin/false \
      $CONSUL_USER  >/dev/null
  fi
}

consul_user_ubuntu() {
  # UBUNTU user setup
  if ! getent group $CONSUL_GROUP >/dev/null
  then
    sudo addgroup --system $CONSUL_GROUP >/dev/null
  fi

  if ! getent passwd $CONSUL_USER >/dev/null
  then
    sudo adduser \
      --system \
      --disabled-login \
      --ingroup ${CONSUL_GROUP} \
      --home ${CONSUL_HOME} \
      --no-create-home \
      --gecos "${CONSUL_COMMENT}" \
      --shell /bin/false \
      $CONSUL_USER  >/dev/null
  fi
}

if [[ ! -z ${YUM} ]]; then
  echo "Setting up Consul user - type RHEL"
  consul_user_rhel
elif [[ ! -z ${APT_GET} ]]; then
  echo "Setting up Consul user - type Ubuntu"
  consul_user_ubuntu
else
  echo "OS Detection failed, consul user not created."
  exit 1;
fi

echo "Setup Consul configuration and data directories"
sudo mkdir -pm 0600 /etc/consul.d /opt/consul/data
sudo cp /tmp/consul/files/config.json /etc/consul.d/config.json
sudo chown -R consul.consul /etc/consul.d /opt/consul
