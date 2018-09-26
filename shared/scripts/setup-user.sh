#!/bin/bash
set -x

echo "Running"

GROUP="${GROUP:-}"
USER="${USER:-}"
COMMENT="${COMMENT:-}"
HOME="${HOME:-}"

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

user_rhel() {
  # RHEL user setup
  sudo /usr/sbin/groupadd --force --system ${GROUP}

  if ! getent passwd ${USER} >/dev/null ; then
    sudo /usr/sbin/adduser \
      --system \
      --gid ${GROUP} \
      --home ${HOME} \
      --no-create-home \
      --comment "${COMMENT}" \
      --shell /bin/false \
      ${USER}  >/dev/null
  fi
}

user_ubuntu() {
  # UBUNTU user setup
  if ! getent group ${GROUP} >/dev/null
  then
    sudo addgroup --system ${GROUP} >/dev/null
  fi

  if ! getent passwd ${USER} >/dev/null
  then
    sudo adduser \
      --system \
      --disabled-login \
      --ingroup ${GROUP} \
      --home ${HOME} \
      --no-create-home \
      --gecos "${COMMENT}" \
      --shell /bin/false \
      ${USER}  >/dev/null
  fi
}

if [[ ! -z ${YUM} ]]; then
  echo "Setting up user ${USER} for RHEL/CentOS"
  user_rhel
elif [[ ! -z ${APT_GET} ]]; then
  echo "Setting up user ${USER} for Debian/Ubuntu"
  user_ubuntu
else
  echo "${USER} user not created due to OS detection failure"
  exit 1;
fi

# Create & set permissions on HOME directory
sudo mkdir -pm 0755 ${HOME}
sudo chown -R ${USER}:${GROUP} ${HOME}
sudo chmod -R 0755 ${HOME}

echo "Complete"
