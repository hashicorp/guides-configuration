# Guides Configuration

This repo contains Packer templates used by HashiCorp Terraform modules in the [hashicorp-modules](https://github.com/hashicorp-modules/) GitHub Org.

### Building HashiStack images locally (outside of the CI pipeline)

This is a workflow that's designed to allow you to trigger local builds of enterprise or OSS Packer images. This functionality is currently under development.

This is particularly useful for customers using Azure, as it's not possible to share machine images.

#### Prerequisites

- Access HashiCorp enterprise binaries
- If you are building Azure images, you'll need to follow the steps at the below links to set up and authenticate with an Azure account
  - [Azure setup instructions](https://github.com/tdsacilowski/azure-consul/blob/master/README.md#deployment-prerequisites)
  - [Azure RM setup guide](https://www.terraform.io/docs/providers/azurerm/index.html)

#### An example using Packer to build images on Azure

After authenticating (see above) with Azure, perform the following steps.

- Authenticate with Azure using the [Azure setup instructions](https://github.com/tdsacilowski/azure-consul/blob/master/README.md#deployment-prerequisites).
- Create a file like the below with your credentials and source it before running the next step.
  **You can skip this step if you want. The `azure-local-env.sh` will take care of it for you, asking you to input each variable that is not already set in your environment.**

  ```
  vi env.sh
  ```

  ```
  #!/bin/bash
  # env.sh
  # Exporting variables in both cases just in case, no pun intended
  export ARM_SUBSCRIPTION_ID="aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
  export ARM_CLIENT_ID="bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
  export ARM_CLIENT_SECRET="cccccccc-cccc-cccc-cccc-cccccccccccc"
  export ARM_TENANT_ID="dddddddd-dddd-dddd-dddd-dddddddddddd"
  export subscription_id="aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
  export client_id="bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
  export client_secret="cccccccc-cccc-cccc-cccc-cccccccccccc"
  ```

  ```
  source env.sh
  ```

- With the root of this repo as your working directory, run the following before each packer build:
  ```
  # Source azure-local-env.sh before each packer build to regenerate URLs,
  # as the enterprise download URLs expire after 10 minutes.
  #
  $ source azure-local-env.sh # aws-local-env.sh for AWS (AWS local build untested)
  $ cd hashistack
  $ packer build hashistack-azure.json
  ```

---

## Consul

Contains Consul specific installation scripts, configuration files. Also has Packer templates specific to Consul usage.

Example AWS Consul build command:

```
source aws-local-env.sh
AWS_REGION="us-west-1" packer build consul-aws.json
```

Example Azure Consul build command:

```
source azure-local-env.sh
AZURE_RESOURCE_GROUP="PackerImages" AZURE_LOCATION="West US" PACKER_ENVIRONMENT="dev" CONSUL_VERSION="0.9.2" packer build consul-azure.json
```

---

## Vault

Contains Vault specific installation scripts, configuration files. Also has Packer templates specific to Vault usage.

Example AWS Vault (including Consul) build command:

```
source aws-local-env.sh
AWS_REGION="us-west-1" packer build vault-aws.json
```

---

## Nomad
Contains Nomad specific installation scripts, configuration files. Also has Packer templates specific to Nomad usage.


Example AWS Nomad (including Consul) build command:

```
source aws-local-env.sh
AWS_REGION="us-west-1" packer build nomad-aws.json
```

---

## HashiStack
Contains provider specific templates that installs HashiCorp software on a single node (Consul, Nomad, Vault, consul-template and envconsul).

Example AWS HashiStack build command:

```
source aws-local-env.sh
AWS_REGION="us-west-1" packer build hashistack-aws.json
```

Example Azure HashiStack build command:

```
source azure-local-env.sh
VCS_NAME="local" PACKER_ENVIRONMENT="production" CONSUL_VERSION="1.2.0" VAULT_VERSION="0.10.3" NOMAD_VERSION="0.8.4" packer build hashistack-azure.json
```

Example GCP HashiStack build command:

```
source gcp-local-env.sh
VCS_NAME="local" PACKER_ENVIRONMENT="production" CONSUL_VERSION="1.2.0" VAULT_VERSION="0.10.3" NOMAD_VERSION="0.8.4" packer build hashistack-gcp.json
```

## Continuous Integration

Product versions for the builds are set on the versions.sh file. This file should be sourced at the start of the CI Build process. The ci-functions.sh file should be sourced at the start of the CI Build process and introduces three functions:

- prepare() will download the ${PACKER_VERSION}
- validate() will run packer validate on the packer templates, for a set of arguments (like consul nomad vault hashistack)
- build() will build and deploy the images

The following script can be used to parallelize the image build process:

```
build consul &
build vault &
build nomad &
build hashistack &

for job in `jobs -p`; do
  echo $job
  wait $job || let "FAIL+=1"
done

echo $FAIL

if [ "$FAIL" == "0" ]; then
  echo -e "\033[32m\033[1m[BUILD SUCCESFUL]\033[0m"
else
  echo -e "\033[31m\033[1m[BUILD ERROR]\033[0m"
fi
```

---

## Some notes on the CI pipeline

- All images are built privately and then their launch permissions are updated by a Terraform Workspace hosted in Atlas (https://atlas.hashicorp.com/terraform/atlas-demo/environments/image-permission-aws/changes/runs).

- Please do not update variables manually on the TFE job. They are updated by the CI process when it runs directly from the `versions.sh` file available in this repository.

## Image Version Table:

|   Release   |   Consul    |   Vault     |   Nomad     |
|-------------|-------------|-------------|-------------|
| 0.1.0       | 1.2.0       | 0.10.3      | 0.8.4       |
| 0.1.1       | 1.2.0-ent   | 0.10.3-ent  | 0.8.4-ent   |
| 0.1.2       | 1.2.1       | 0.10.3      | 0.8.4       |
| 0.1.3       | 1.2.1-ent   | 0.10.3-ent  | 0.8.4-ent   |
