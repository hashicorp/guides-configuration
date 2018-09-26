#!/bin/bash
set -x

echo "Running"

GROUP=${GROUP:-"default"}
USER=${USER:-"default"}
PASSWORD=${PASSWORD:-"default"}
COMMENT=${COMMENT:-"SSH User"}

echo "Detect package management system"
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

user_rhel() {
  echo "RHEL user setup"
  echo "Add group ${GROUP}"
  sudo /usr/sbin/groupadd --force ${GROUP}

  if ! getent passwd ${USER} >/dev/null ; then
    echo "Add user ${USER}"
    sudo /usr/sbin/adduser \
      --gid ${GROUP} \
      --create-home \
      --comment "${COMMENT}" \
      --shell /bin/bash \
      ${USER}  >/dev/null
  else
    echo "User ${USER} already created"
  fi

  echo "Disable SELinux as you get the error \"login -- <user>: no shell: Permission denied\""
  sudo sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  sudo setenforce 0
}

user_ubuntu() {
  echo "Ubuntu user setup"
  if ! getent group ${GROUP} >/dev/null
  then
    echo "Add group ${GROUP}"
    sudo addgroup ${GROUP} >/dev/null
  else
    echo "Group ${GROUP} already created"
  fi

  if ! getent passwd ${USER} >/dev/null
  then
    echo "Add user ${USER}"
    sudo useradd "${USER}" \
      --gid ${GROUP} \
      --shell /bin/bash \
      --create-home  >/dev/null
  else
    echo "User ${USER} already created"
  fi

  sudo usermod -a -G sudo "${USER}"
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

echo "Set password"
echo "${USER}:${PASSWORD}" | sudo chpasswd

echo "Add /etc/sudoers.d/${USER}"
sudo tee "/etc/sudoers.d/${USER}" > /dev/null <<EOF
${USER} ALL=(ALL) NOPASSWD:ALL
EOF

sudo chmod 0440 "/etc/sudoers.d/${USER}"
sudo su "${USER}" -c "ssh-keygen -q -t rsa -N '' -b 4096 -f ~/.ssh/id_rsa -C hello@hashicorp.com"

sudo sed -i "/^PasswordAuthentication/c\PasswordAuthentication yes" /etc/ssh/sshd_config
sudo systemctl restart sshd

echo "Complete"
