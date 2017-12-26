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
  for PRODUCT in $*; do
    echo "Reviewing ${PRODUCT} template ...             "
    cd "${BUILDDIR}/${PRODUCT}"
    if /tmp/packer validate ${PRODUCT}.json; then
      echo -e "\033[32m\033[1m[PASS]\033[0m"
    else
      echo -e "\033[31m\033[1m[FAIL]\033[0m"
      return 1
    fi
    cd -
  done
  echo "Reviewing shell scripts ..."
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


build () {
export CONSUL_RELEASE="${CONSUL_VERSION}"
export NOMAD_RELEASE="${NOMAD_VERSION}"
export VAULT_RELEASE="${VAULT_VERSION}"

if [[ $1 =~ .*ent ]] ; then
  PRODUCT=${1/-ent/}
  echo "Building $PRODUCT Enterprise template ...       "
  export CONSUL_VERSION="${CONSUL_VERSION}+ent"
  export NOMAD_VERSION="${NOMAD_RELEASE}+ent"
  export VAULT_VERSION="${VAULT_VERSION}+ent"
  export CONSUL_ENT_URL=${_CONSUL_ENT_URL}
  export VAULT_ENT_URL=${_VAULT_ENT_URL}
  export NOMAD_ENT_URL=${_NOMAD_ENT_URL}
  export DISTRIBUTION="ent"
else
  PRODUCT=$1  
  echo "Building $PRODUCT OSS template ...       "
  export CONSUL_ENT_URL=''
  export VAULT_ENT_URL=''
  export NOMAD_ENT_URL=''
  export DISTRIBUTION="oss"
fi  

cd "${BUILDDIR}/${PRODUCT}"
export TMPDIR="/tmp/${PRODUCT}-$((1 + RANDOM % 100))"
mkdir -p $TMPDIR
if /tmp/packer build ${PRODUCT}.json ; then
  echo -e "\033[32m${PRODUCT} \033[1m[PASS]\033[0m"
else
  echo -e "\033[31m${PRODUCT} \033[1m[FAIL]\033[0m"
  return 1
fi
cd -
done
}

presign_ent_url () {
  if [ $# -eq 0 ]; then
    echo -e "\033[31m\033[1m[FAIL - no product name provided]\033[0m"
    return 1
  fi
  
  _AWS_SECRET_ACCESS_KEY=$(echo $AWS_SECRET_ACCESS_KEY_BINARY | base64 -d | gpg -d -)
  _AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID_BINARY}
  _REGION="us-east-1"

  if [ $1 = "consul" ]; then
    S3_URL=s3://${S3BUCKET}/consul-enterprise/${CONSUL_VERSION}/consul-enterprise_${CONSUL_VERSION}+ent_linux_amd64.zip
  elif [ $1 = "vault" ]; then
    S3_URL=s3://${S3BUCKET}/vault/prem/${VAULT_VERSION}/vault-enterprise_${VAULT_VERSION}+prem_linux_amd64.zip
  elif [ $1 = "nomad" ]; then
    S3_URL=s3://${S3BUCKET}/nomad-enterprise/${NOMAD_VERSION}/nomad-enterprise_${NOMAD_VERSION}+ent_linux_amd64.zip
  else
    echo -e "\033[31m\033[1m[FAIL - invalid product selection for S3 enterprise URL]\033[0m"
    return 1
  fi

  echo "$(AWS_SECRET_ACCESS_KEY=${_AWS_SECRET_ACCESS_KEY} \
    AWS_ACCESS_KEY_ID=${_AWS_ACCESS_KEY_ID} \
    aws s3 presign \
    --region=${_REGION} \
    ${S3_URL} )"
}

publish () {

  git clone https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/hashicorp-modules/image-permission-aws
  cd image-permission-aws
  /tmp/terraform init
  /tmp/terraform push -var "consul_version=${CONSUL_VERSION}" \
    -var "vault_version=${VAULT_VERSION}" \
    -var "nomad_version=${NOMAD_VERSION}" \
    -overwrite=consul_version \
    -overwrite=vault_version \
    -overwrite=nomad_version \
    -name=atlas-demo/image-permission-aws .
}