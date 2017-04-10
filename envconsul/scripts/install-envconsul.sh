#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT envconsul-install.sh: $1"
}

ENVCONSUL_VERSION=${VERSION:-0.6.2}
ENVCONSUL_ZIP=/tmp/envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip
ENVCONSUL_URL="https://releases.hashicorp.com/envconsul/${ENVCONSUL_VERSION}/envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip"
ENVCONSUL_USER=${USER:-}
ENVCONSUL_GROUP=${GROUP:-}

cd /tmp
logger "Downloading envconsul"
wget $ENVCONSUL_URL --quiet -O $ENVCONSUL_ZIP

logger "Unpacking envconsul"
unzip -q $ENVCONSUL_ZIP >/dev/null
rm -f $ENVCONSUL_ZIP

logger "Installing envconsul"
sudo chmod +x envconsul
sudo mv envconsul /usr/local/bin
sudo chmod 0755 /usr/local/bin/envconsul
sudo chown root:root /usr/local/bin/envconsul

logger "Installed envconsul version is $(envconsul --version 2>&1)"

logger "Setup envconsul configuration directory"
sudo mkdir -pm 0600 /etc/envconsul.d
sudo chmod -R 0755 /etc/envconsul.d
sudo chown -R ${ENVCONSUL_USER}.${ENVCONSUL_GROUP} /etc/envconsul.d

logger "Complete"
