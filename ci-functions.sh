# This script includes a set of generic CI functions to test Packer Builds.
prepare () {
  rm -rf /tmp/packer
  curl -o /tmp/packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
  unzip /tmp/packer.zip -d /tmp
  chmod +x /tmp/packer
}

validate () {
  for PRODUCT in $*; do
    echo "Reviewing ${PRODUCT} template ...             "
    cd "${BUILDDIR}/${PRODUCT}"
    if /tmp/packer validate *.json > /dev/null; then
      echo -e "\033[32m\033[1m[PASS]\033[0m"
    else
      echo -e "\033[31m\033[1m[FAIL]\033[0m"
      return 1
    fi
    cd -
  done
}

build () {
  for PRODUCT in $*; do
    echo "Building ${PRODUCT} template ...             "
    cd "${BUILDDIR}/${PRODUCT}"
    if /tmp/packer build *.json ; then
      echo -e "\033[32m${PRODUCT} \033[1m[PASS]\033[0m"
    else
      echo -e "\033[31m${PRODUCT} \033[1m[FAIL]\033[0m"
      return 1
    fi
    cd -
  done
}
