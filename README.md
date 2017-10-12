# Intro
This repo contains Packer templates used for modules in hashicorp-modules

---

## HashiStack  
Contains provider specific templates that installs HashiCorp software on a single node (Consul, Nomad, Vault, consul-template and envconsul).

Example HashiStack build command:

```
AWS_REGION="us-west-1" PACKER_ENVIRONMENT="production" CONSUL_VERSION="0.9.2" NOMAD_VERSION="0.5.6" VAULT_VERSION="0.7.3" packer build hashistack.json
```

### Building HashiStack images locally (outside of the CI pipeline)
This is a workflow that's designed to allow you to trigger local builds of enterprise or OSS Packer images. This functionality is currently under development. The Azure example below is all that's been tested.

This is particularly useful for customers using Azure, as it's not possible to share machine images with them.

#### Prerequisites
- If you don't already have credentials to access HashiCorp enterprise binaries, add an appropriate entry for yourself (if you're an employee) in the [licensing binaries repository](https://github.com/hashicorp/licensing-binaries).
- After adding yourself, you can find your credentials in the output of this [terraform job](https://tfe.hashicorp.engineering/terraform/licensing/environments/binaries/changes/runs).
  - The above procedure for getting your binary credentials is documented in the [SE Handbook](https://docs.google.com/document/d/1lRYgJMIGejYbaxTpZmc3hnbj7aWRg7dFXCN3_x87mYQ/edit#heading=h.6blw4fxx8vz1).
- If you are building Azure images, you'll need to follow the steps at the below links to set up and authenticate with an Azure account.
  - [Azure setup instructions](https://github.com/tdsacilowski/azure-consul/blob/master/README.md#deployment-prerequisites)
  - This [Azure RM setup guide](https://www.terraform.io/docs/providers/azurerm/index.html) is linked in the above documentation.

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

***Notes:***
- Right now using the [hashistack-azure](https://github.com/hashicorp-guides/hashistack/tree/chad_hashistack_azure/terraform-azure) and an image resulting from the above, it's possible to deploy a HashiStack cluster (some functional tests pending) on Ubuntu and RHEL. You may need to start Vault on RHEL.
- Make sure to source `azure-local-env.sh` or `aws-local-env.sh` before each packer build as the AWS enterprise download URLs expire after 10 minutes.
- If someone has time to test this process on an AWS build, it would help. Mainly, I suspect the AWS credential variables to download binaries will conflict with local AWS credential environment variables.

---

## Consul
Contains Consul specific installation scripts, configuration files.  Also has Packer templates specific to Consul usage.

Example Consul build command (AWS):

```
AWS_REGION="us-west-1" PACKER_ENVIRONMENT="production" CONSUL_VERSION="0.9.2" packer build consul-aws.json
```

Example Consul build command (Azure):

```
AZURE_RESOURCE_GROUP="PackerImages" AZURE_LOCATION="West US" PACKER_ENVIRONMENT="dev" CONSUL_VERSION="0.9.2" packer build consul-azure.json
```

---

## Nomad  
Contains Nomad specific installation scripts, configuration files.  Also has Packer templates specific to Nomad usage.


Example Nomad (including Consul) build command:

```
AWS_REGION="us-west-1" PACKER_ENVIRONMENT="production" NOMAD_VERSION="0.5.6" CONSUL_VERSION="0.9.2" packer build nomad.json
```

---

## Vault    
Contains Vault specific installation scripts, configuration files.  Also has Packer templates specific to Vault usage.

Example Vault (including Consul) build command:

```
AWS_REGION="us-west-1" PACKER_ENVIRONMENT="production" VAULT_VERSION="0.7.3" CONSUL_VERSION="0.9.2" packer build vault.json
```

## Continuous Integration
Product versions for the builds are set on the versions.sh file. This file should be sourced at the start of the CI Build process.
The ci-functions.sh file should be sourced at the start of the CI Build process and introduces three functions:
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

## Hashistack Version Tables:

| Nomad | Consul | Vault |
|-------|--------|-------|
| 0.5.6 | 0.8.4  | 0.7.3 |
| 0.6.0 | 0.8.4  | 0.7.3 |
| 0.6.0 | 0.8.4  | 0.8.0 |
| 0.6.0 | 0.9.2  | 0.8.0 |
| 0.6.0 | 0.9.2  | 0.8.1 |
| 0.6.2 | 0.9.2  | 0.8.1 |
