  # Variables you'll need to build locally
  # You'll need to override your AWS credentials with the ones given to you
  # via this repo: https://github.com/hashicorp/licensing-binaries
  # and this job: https://tfe.hashicorp.engineering/terraform/licensing/environments/binaries/changes/runs
  #
  # The procedure for getting your binary credentials is documented in the [SE Handbook](https://docs.google.com/document/d/1lRYgJMIGejYbaxTpZmc3hnbj7aWRg7dFXCN3_x87mYQ/edit#heading=h.6blw4fxx8vz1)
  #
  # Below is one example of how to use it
  # First, authenticate with Azure using this guide: https://www.terraform.io/docs/providers/azurerm/authenticating_via_azure_cli.html
  # There are also some useful tips for authenticating here: https://github.com/tdsacilowski/azure-consul
  # Example (order is important as local-variables.sh depends on variables in versions.sh):
  # $ cd hashistack
  # $ source ../versions.sh
  # $ source ../local-variables.sh
  # AZURE_RESOURCE_GROUP="PackerImages" AZURE_LOCATION="West US" PACKER_ENVIRONMENT="dev" packer build hashistack-azure.json
  #
  export S3BUCKET="${S3BUCKET}"
  export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
  export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
  export CONSUL_RELEASE="${CONSUL_VERSION}"
  export VAULT_RELEASE="${VAULT_VERSION}"
  export CONSUL_VERSION="${CONSUL_VERSION}"
  export VAULT_VERSION="${VAULT_VERSION}"
  export DISTRIBUTION="ent"
  export VAULT_VERSION="${VAULT_RELEASE}"
  export CONSUL_VERSION="${CONSUL_RELEASE}"
  # Re-source this file for every Packer run to re-generate URLs
  # They are set to expire after 10 minutes
  export CONSUL_ENT_URL=$(AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" aws s3 presign --region="us-east-1" s3://${S3BUCKET}/consul-enterprise/${CONSUL_VERSION}/consul-enterprise_${CONSUL_VERSION}+ent_linux_amd64.zip --expires-in 600)
  export VAULT_ENT_URL=$(AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" aws s3 presign --region="us-east-1" s3://${S3BUCKET}/vault-enterprise/${VAULT_VERSION}/vault-enterprise_${VAULT_VERSION}_linux_amd64.zip --expires-in 600)

  # Feel free to comment out the below reminder if you're familiar with this process
  echo -e "\n\033[0;32mBe sure to export following before sourcing/re-sourcing this file in order to access enterprise binaries:\n"
  echo -e "export S3BUCKET=<enterprise bucket name>
export AWS_ACCESS_KEY_ID=<your aws enterprise binary access key id>
export AWS_SECRET_ACCESS_KEY=<your aws enterprise binary access key>\033[0m"
