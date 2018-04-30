#!/bin/bash

# This script includes a set of generic CI functions to test Packer Builds.
prepare () {
  rm -rf /tmp/packer
  curl -o /tmp/packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
  unzip /tmp/packer.zip -d /tmp
  chmod +x /tmp/packer
  rm -rf /tmp/terraform
  curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  unzip /tmp/terraform.zip -d /tmp
  chmod +x /tmp/terraform
}

validate () {
  for TEMPLATE in $*; do
    echo "cd into ${TEMPLATE} directory"
    cd ${BUILDDIR}/$(echo ${TEMPLATE} | sed 's/-.*//')
    echo "Reviewing ${TEMPLATE}.json template..."

    if /tmp/packer validate ${TEMPLATE}.json; then
      echo -e "\033[32m\033[1m[PASS]\033[0m"
    else
      echo -e "\033[31m\033[1m[FAIL]\033[0m"
      return 1
    fi

    cd -
  done

  echo "Reviewing shell scripts..."
  if find . -iname \*.sh -exec bash -n {} \; > /dev/null; then
    echo -e "\033[32m\033[1m[PASS]\033[0m"
  else
    echo -e "\033[31m\033[1m[FAIL]\033[0m"
    return 1
  fi
}

gpg_import () {
  echo ${PGP_SECRET_KEY} | base64 -d | gpg --import
}

presign_ent_url () {
  if [ $# -eq 0 ]; then
    echo -e "\033[31m\033[1m[FAIL - no variables provided]\033[0m"
    return 1
  fi

  if [ $1 -eq 0 ]; then
    echo -e "\033[31m\033[1m[FAIL - no product name provided]\033[0m"
    return 1
  fi

  if [ $2 -eq 0 ]; then
    echo -e "\033[31m\033[1m[FAIL - no product version provided]\033[0m"
    return 1
  fi

  _AWS_SECRET_ACCESS_KEY=$(echo $AWS_SECRET_ACCESS_KEY_BINARY | base64 -d | gpg -d -)
  _AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID_BINARY}
  _REGION="us-east-1"
  _PRODUCT=$1
  _VERSION=$2

  if [ ${_PRODUCT} = "consul" ]; then
    _S3_URL=s3://${S3BUCKET}/consul-enterprise/${_VERSION}/consul-enterprise_${_VERSION}+ent_linux_amd64.zip
  elif [ ${_PRODUCT} = "vault" ]; then
    _S3_URL=s3://${S3BUCKET}/vault/prem/${_VERSION}/vault-enterprise_${_VERSION}+prem_linux_amd64.zip
  elif [ ${_PRODUCT} = "nomad" ]; then
    _S3_URL=s3://${S3BUCKET}/nomad-enterprise/${_VERSION}/nomad-enterprise_${_VERSION}+ent_linux_amd64.zip
  else
    echo -e "\033[31m\033[1m[FAIL - invalid product selection for S3 enterprise URL]\033[0m"
    return 1
  fi

  echo "$(AWS_SECRET_ACCESS_KEY=${_AWS_SECRET_ACCESS_KEY} \
    AWS_ACCESS_KEY_ID=${_AWS_ACCESS_KEY_ID} \
    aws s3 presign \
    --region=${_REGION} \
    ${_S3_URL} )"
}

prepare_ent_urls () {
  if [[ ${CONSUL_VERSION} == *"ent"* ]]; then
    export CONSUL_VERSION_STRIPPED=${CONSUL_VERSION/"-ent"/}
    export CONSUL_ENT_URL=$(presign_ent_url consul ${CONSUL_VERSION_STRIPPED})
    echo "CONSUL_VERSION_STRIPPED: ${CONSUL_VERSION_STRIPPED}"
    echo "CONSUL_ENT_URL: ${CONSUL_ENT_URL}"
    # export CONSUL_ENT_URL=$(AWS_SECRET_ACCESS_KEY=$(echo $AWS_SECRET_ACCESS_KEY_BINARY | base64 -d | gpg -d -) AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID_BINARY} aws s3 presign --region="us-east-1" s3://${S3BUCKET}/consul-enterprise/${CONSUL_VERSION_STRIPPED}/consul-enterprise_${CONSUL_VERSION}_linux_amd64.zip)

    # Replacing '+' with '-' as '+' is an invalid character for the AMI name and
    # the version isn't used during the install when 'CONSUL_ENT_URL' is populated
    # export CONSUL_VERSION=${CONSUL_VERSION/'+'/'-'}
    echo "CONSUL_VERSION: ${CONSUL_VERSION}"
  fi

  if [[ ${VAULT_VERSION} == *"ent"* ]]; then
    export VAULT_VERSION_STRIPPED=${VAULT_VERSION/"-ent"/}
    export VAULT_ENT_URL=$(presign_ent_url vault ${VAULT_VERSION_STRIPPED})
    echo "VAULT_VERSION_STRIPPED: ${VAULT_VERSION_STRIPPED}"
    echo "VAULT_ENT_URL: ${VAULT_ENT_URL}"
    # export VAULT_ENT_URL=$(AWS_SECRET_ACCESS_KEY=$(echo $AWS_SECRET_ACCESS_KEY_BINARY | base64 -d | gpg -d -) AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID_BINARY} aws s3 presign --region="us-east-1" s3://${S3BUCKET}/vault-enterprise/${VAULT_VERSION_STRIPPED}/vault-enterprise_${VAULT_VERSION_STRIPPED}_linux_amd64.zip)

    # Replacing '+' with '-' as '+' is an invalid character for the AMI name and
    # the version isn't used during the install when 'VAULT_ENT_URL' is populated
    # export VAULT_VERSION=${VAULT_VERSION/'+'/'-'}
    echo "VAULT_VERSION: ${VAULT_VERSION}"
  fi

  if [[ ${NOMAD_VERSION} == *"ent"* ]]; then
    export NOMAD_VERSION_STRIPPED=${NOMAD_VERSION/"-ent"/}
    export NOMAD_ENT_URL=$(presign_ent_url nomad ${NOMAD_VERSION_STRIPPED})
    echo "NOMAD_VERSION_STRIPPED: ${NOMAD_VERSION_STRIPPED}"
    echo "NOMAD_ENT_URL: ${NOMAD_ENT_URL}"
    # export NOMAD_ENT_URL=$(AWS_SECRET_ACCESS_KEY=$(echo $AWS_SECRET_ACCESS_KEY_BINARY | base64 -d | gpg -d -) AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID_BINARY} aws s3 presign --region="us-east-1" s3://${S3BUCKET}/vault-enterprise/${NOMAD_VERSION_STRIPPED}/vault-enterprise_${NOMAD_VERSION_STRIPPED}_linux_amd64.zip)

    # Replacing '+' with '-' as '+' is an invalid character for the AMI name and
    # the version isn't used during the install when 'NOMAD_ENT_URL' is populated
    # export NOMAD_VERSION=${NOMAD_VERSION/'+'/'-'}
    echo "NOMAD_VERSION: ${NOMAD_VERSION}"
  fi
}

build () {
  if [ -z ${RELEASE_VERSION} ]; then
    # Set RELEASE_VERSION to the current git branch if not specified so it's not empty
    export RELEASE_VERSION=${GIT_BRANCH}
  fi

  if [ -z ${USER_TRIGGER+x} ]; then
    export VCS_NAME="Manual"
  else
    export VCS_NAME=${GIT_BRANCH}
  fi

  echo "Starting build from ${GIT_BRANCH}"
  echo "RELEASE_VERSION: ${RELEASE_VERSION}"
  echo "VCS_NAME: ${VCS_NAME}"
  echo "Building Consul version: ${CONSUL_VERSION}"
  echo "Building Vault version: ${VAULT_VERSION}"
  echo "Building Nomad version: ${NOMAD_VERSION}"

  for TEMPLATE in $*; do
    echo "cd into ${TEMPLATE} directory"
    cd ${BUILDDIR}/$(echo ${TEMPLATE} | sed 's/-.*//')
    echo "Building ${TEMPLATE}.json Packer template..."

    if /tmp/packer build ${TEMPLATE}.json ; then
      echo -e "\033[32m${TEMPLATE} \033[1m[PASS]\033[0m"
    else
      echo -e "\033[31m${TEMPLATE} \033[1m[FAIL]\033[0m"
      return 1
    fi

    cd -
  done

  echo "Cleaning up GPG Keyring..."
  gpg --fingerprint --with-colons ${PGP_SECRET_ID} |\
    grep "^fpr" |\
    sed -n 's/^fpr:::::::::\([[:alnum:]]\+\):/\1/p' |\
    xargs gpg --batch --delete-secret-keys

  echo "Completed build from ${GIT_BRANCH}"
}

publish () {
  # Exit early if not on master branch or RUN_PUBLISH env var not passed
  echo "GIT_BRANCH: ${GIT_BRANCH}"
  echo "RUN_PUBLISH: ${RUN_PUBLISH}"

  if ! [[ ${GIT_BRANCH} == *"master"* ]] && [ -z ${RUN_PUBLISH} ]; then
    echo "Do not publish, exit early"
    exit 0
  fi

  export PATH=$PATH:/tmp
  rm -rf tf-se-ami-permissions
  git clone --recurse-submodules https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/hashicorp/tf-se-ami-permissions
  cd tf-se-ami-permissions

  /tmp/terraform init
  ./tfe-cli/bin/tfe pushvars -var "consul_version=${CONSUL_VERSION}" -overwrite consul_version
  ./tfe-cli/bin/tfe pushvars -var "nomad_version=${NOMAD_VERSION}" -overwrite nomad_version
  ./tfe-cli/bin/tfe pushvars -var "vault_version=${VAULT_VERSION}" -overwrite vault_version
  ./tfe-cli/bin/tfe pushconfig
}
