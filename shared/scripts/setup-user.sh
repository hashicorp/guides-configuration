#!/usr/bin/env bash
set -x

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT setup-user.sh: $1"
}

USER="${USER:-}"
COMMENT="${COMMENT:-}"
GROUP="${GROUP:-}"
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
  logger "Setting up user ${USER} for RHEL/CentOS"
  user_rhel
elif [[ ! -z ${APT_GET} ]]; then
  logger "Setting up user ${USER} for Ubuntu/Debian"
  user_ubuntu
else
  logger "OS Detection failed, ${USER} user not created."
  exit 1;
fi

logger "Complete"
