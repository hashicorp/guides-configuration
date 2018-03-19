#!/bin/bash
# azure-local-env.sh
#
# Variables you'll need to trigger Packer image builds locally
# If you have an ~/.aws/credentials file, you'll need to override that with
# the credentials given to you via this repo: https://github.com/hashicorp/licensing-binaries
# and this job: https://tfe.hashicorp.engineering/terraform/licensing/environments/binaries/changes/runs
#
# The procedure for getting your binary credentials is documented in the [SE Handbook](https://docs.google.com/document/d/1lRYgJMIGejYbaxTpZmc3hnbj7aWRg7dFXCN3_x87mYQ/edit#heading=h.6blw4fxx8vz1)
#
# Below is one example of how to use it
# First, authenticate with Azure using this guide: https://www.terraform.io/docs/providers/azurerm/authenticating_via_azure_cli.html
# There are also some useful tips for authenticating here: https://github.com/tdsacilowski/azure-consul
#
## Example usage:
#
# $ cd /root/of/this/repository
# $ source local-build-env.sh
# $ cd hashistack # or cd into any dir containing an Azure Packer build file
# $ packer build hashistack-azure.json
#

# Source versions from this repository
source versions.sh

if [ -z ${S3BUCKET} ]; then
  read -p $'\033[1;32mPlease enter an S3 bucket name for enterprise binary download: \033[0m' S3BUCKET
  export S3BUCKET="${S3BUCKET}"
else
  export S3BUCKET="${S3BUCKET}"
fi

if [ -z ${AWS_ACCESS_KEY_ID} ]; then
  read -p $'\033[1;32mPlease enter an AWS access key ID for enterprise binary download: \033[0m' AWS_ACCESS_KEY_ID
  export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
else
  export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
fi

if [ -z ${AWS_SECRET_ACCESS_KEY} ]; then
  read -p $'\033[1;32mPlease enter an AWS secret access key for enterprise binary download: \033[0m' AWS_SECRET_ACCESS_KEY
  export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
else
  export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
fi

if [ -z ${AZURE_RESOURCE_GROUP} ]; then
  read -p $'\033[1;32mPlease enter an Azure resource group for image creation and storage: \033[0m' AZURE_RESOURCE_GROUP
  export AZURE_RESOURCE_GROUP="${AZURE_RESOURCE_GROUP}"
else
  export AZURE_RESOURCE_GROUP="${AZURE_RESOURCE_GROUP}"
fi

if [ -z "${AZURE_LOCATION}" ]; then
  read -p $'\033[1;32mPlease enter an Azure location for image creation: \033[0m' AZURE_LOCATION
  export AZURE_LOCATION="${AZURE_LOCATION}"
else
  export AZURE_LOCATION="${AZURE_LOCATION}"
fi

if [ -z ${PACKER_ENVIRONMENT} ]; then
  read -p $'\033[1;32mPlease enter an environment tag for your image: \033[0m' PACKER_ENVIRONMENT
  export PACKER_ENVIRONMENT="${PACKER_ENVIRONMENT}"
else
  export PACKER_ENVIRONMENT="${PACKER_ENVIRONMENT}"
fi

###

if [ -z ${ARM_SUBSCRIPTION_ID} ]; then
  read -p $'\033[1;32mPlease enter your Azure subscription ID: \033[0m' ARM_SUBSCRIPTION_ID
  export ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}"
  export subscription_id="${ARM_SUBSCRIPTION_ID}"
else
  export ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}"
  export subscription_id="${ARM_SUBSCRIPTION_ID}"
fi

if [ -z ${ARM_CLIENT_ID} ]; then
  read -p $'\033[1;32mPlease enter your Azure client ID: \033[0m' ARM_CLIENT_ID
  export ARM_CLIENT_ID="${ARM_CLIENT_ID}"
  export client_id="${ARM_CLIENT_ID}"
else
  export ARM_CLIENT_ID="${ARM_CLIENT_ID}"
  export client_id="${ARM_CLIENT_ID}"
fi

if [ -z ${ARM_CLIENT_SECRET} ]; then
  read -p $'\033[1;32mPlease enter your Azure client secret: \033[0m' ARM_CLIENT_SECRET
  export ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}"
  export client_secret="${ARM_CLIENT_SECRET}"
else
  export ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}"
  export client_secret="${ARM_CLIENT_SECRET}"
fi

if [ -z ${ARM_TENANT_ID} ]; then
  read -p $'\033[1;32mPlease enter your Azure tenant ID: \033[0m' ARM_TENANT_ID
  export ARM_TENANT_ID="${ARM_TENANT_ID}"
else
  export ARM_TENANT_ID="${ARM_TENANT_ID}"
fi

if [ -z ${PACKER_ENVIRONMENT} ]; then
  read -p $'\033[1;32mPlease enter an environment tag for your image: \033[0m' PACKER_ENVIRONMENT
  export PACKER_ENVIRONMENT="${PACKER_ENVIRONMENT}"
else
  export PACKER_ENVIRONMENT="${PACKER_ENVIRONMENT}"
fi

export VCS_NAME="local"
export CONSUL_RELEASE="${CONSUL_VERSION}"
export NOMAD_RELEASE="${NOMAD_VERSION}"
export VAULT_RELEASE="${VAULT_VERSION}"
export CONSUL_VERSION="${CONSUL_VERSION}"
export NOMAD_VERSION="${NOMAD_VERSION}"
export VAULT_VERSION="${VAULT_VERSION}"
export DISTRIBUTION="ent"
export CONSUL_VERSION="${CONSUL_RELEASE}"
export VAULT_VERSION="${VAULT_RELEASE}"
export NOMAD_VERSION="${NOMAD_RELEASE}"
# Re-source this file for every Packer run to re-generate URLs
# They are set to expire after 10 minutes
export CONSUL_ENT_URL=$(AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
  aws s3 presign \
  --region="us-east-1" \
  s3://${S3BUCKET}/consul-enterprise/${CONSUL_VERSION}/consul-enterprise_${CONSUL_VERSION}+ent_linux_amd64.zip \
  --expires-in 600)
export VAULT_ENT_URL=$(AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
  aws s3 presign \
  --region="us-east-1" \
  s3://${S3BUCKET}/vault/prem/${VAULT_VERSION}/vault-enterprise_${VAULT_VERSION}+prem_linux_amd64.zip \
  --expires-in 600)
export NOMAD_ENT_URL=$(AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
  aws s3 presign \
  --region="us-east-1" \
  s3://${S3BUCKET}/nomad-enterprise/${NOMAD_VERSION}/nomad-enterprise_${NOMAD_VERSION}+ent_linux_amd64.zip \
  --expires-in 600)

# Feel free to comment out the below reminder if you're familiar with this process
echo -e '\n\033[0;32mBinary downloads generated by this script expire in 10 minutes.'
echo -e 'Make sure to re-source this file to regenerate URLs for every Packer build. \033[0m'
