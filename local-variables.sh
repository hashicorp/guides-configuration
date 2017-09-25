  # Variables you'll need to build locally
  # You'll need to override your AWS credentials with the ones given to you
  # via this repo: https://github.com/hashicorp/licensing-binaries
  # and this job: https://tfe.hashicorp.engineering/terraform/licensing/environments/binaries/changes/runs
  #
  # Below is one example of how to use it
  # First, authenticate with Azure using this guide: https://www.terraform.io/docs/providers/azurerm/authenticating_via_azure_cli.html
  # There are also some useful tips for authenticating here: https://github.com/tdsacilowski/azure-consul
  # Example:
  # $ cd hashistack
  # $ source ../versions.sh
  # $ source ../local-variables.sh
  # AZURE_RESOURCE_GROUP="PackerImages" AZURE_LOCATION="West US" PACKER_ENVIRONMENT="dev" packer build hashistack-azure.json
  #
  export CONSUL_ENT_URL=$(AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" aws s3 presign --region="us-east-1" s3://${S3BUCKET}/consul-enterprise/${CONSUL_VERSION}/consul-enterprise_${CONSUL_VERSION}+ent_linux_amd64.zip --expires-in 600)
  export VAULT_ENT_URL=$(AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" aws s3 presign --region="us-east-1" s3://${S3BUCKET}/vault-enterprise/${VAULT_VERSION}/vault-enterprise_${VAULT_VERSION}_linux_amd64.zip --expires-in 600)
  export CONSUL_RELEASE="${CONSUL_VERSION}"
  export VAULT_RELEASE="${VAULT_VERSION}"
  export CONSUL_VERSION="${CONSUL_VERSION}+ent"
  export VAULT_VERSION="${VAULT_VERSION}+ent"
  export DISTRIBUTION="ent"
  export VAULT_VERSION="${VAULT_RELEASE}"
  export CONSUL_VERSION="${CONSUL_RELEASE}"
