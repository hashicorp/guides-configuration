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
This is a workflow that's designed to allow you to trigger local builds of enterprise Packer images. This functionality is currently under development. The example below is all that's been tested.

This is particularly useful for customers on Azure, as it's difficult to share machine images with them.

#### Prerequisites
- If you don't already have credentials to access HashiCorp enterprise binaries, add an appropriate entry for yourself (if you're an employee) in the [licensing binaries repository](https://github.com/hashicorp/licensing-binaries).
- After adding yourself, you can find your credentials in the output of this [terraform job](https://tfe.hashicorp.engineering/terraform/licensing/environments/binaries/changes/runs).
  - The above procedure for getting your binary credentials is documented in the [SE Handbook](https://docs.google.com/document/d/1lRYgJMIGejYbaxTpZmc3hnbj7aWRg7dFXCN3_x87mYQ/edit#heading=h.6blw4fxx8vz1).
- If you are building Azure images, you'll need to follow the steps at the below links to set up and authenticate with an Azure account.
  - [Azure setup instructions](https://github.com/tdsacilowski/azure-consul/blob/master/README.md#deployment-prerequisites)
  - This [Azure RM setup guide](https://www.terraform.io/docs/providers/azurerm/index.html) is linked in the above documentation.

#### An example using Packer to build images on Azure
After authenticating (see above) with Azure, perform the following steps.

- Starting with this repo as the root, run the following:
  ```
  $ cd hashistack
  $ source ../versions.sh
  $ source ../local-variables.sh
  $ AZURE_RESOURCE_GROUP="PackerImages" AZURE_LOCATION="West US" PACKER_ENVIRONMENT="dev" packer build hashistack-azure.json
  ```

***Notes:***
- Right now using [Teddy Sacilowski's Azure Consul terraform config](https://github.com/tdsacilowski/azure-consul) and an image resulting from the above, it's possible to deploy a HashiStack cluster (functionality untestested as of yet) on Ubuntu and RHEL. However, the RHEL deployment is currently inaccessible via SSH due to an unknown bug.
- Make sure to source `versions.sh` and `local-variables.sh` before each packer build as the AWS enterprise download URLs expire after 10 minutes.

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

## Hashistack Version Tables:

| Nomad | Consul | Vault |
|-------|--------|-------|
| 0.5.6 | 0.8.4  | 0.7.3 |
| 0.6.0 | 0.8.4  | 0.7.3 |
| 0.6.0 | 0.8.4  | 0.8.0 |
| 0.6.0 | 0.9.2  | 0.8.0 |
| 0.6.0 | 0.9.2  | 0.8.1 |
| 0.6.2 | 0.9.2  | 0.8.1 |
