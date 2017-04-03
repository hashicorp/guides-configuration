#!/usr/bin/env bash
set -x

ENVCONSUL_VERSION=${VERSION:-0.6.2}
ENVCONSUL_ZIP=/tmp/envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip
ENVCONSUL_URL="https://releases.hashicorp.com/envconsul/${ENVCONSUL_VERSION}/envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip"

cd /tmp
echo "Downloading envconsul"
wget $ENVCONSUL_URL --quiet -O $ENVCONSUL_ZIP

echo "Unpacking Consul Template"
unzip -q $ENVCONSUL_ZIP >/dev/null
rm -f $ENVCONSUL_ZIP

echo "Installing envconsul"
sudo chmod +x envconsul
sudo mv envconsul /usr/local/bin
sudo chmod 0755 /usr/local/bin/envconsul
sudo chown root:root /usr/local/bin/envconsul

echo "Installed envconsul version is $(envconsul --version 2>&1)"
