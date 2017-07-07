# Intro
This repo contains Packer templates used for modules in hashicorp-modules

---

## hashistack  
Contains provider specific templates that installs HashiCorp software on a single node (Consul, Nomad, Vault, consul-template and envconsul).

Example HashiStack build command:

```
AWS_REGION="us-west-1" PACKER_ENVIRONMENT="production" CONSUL_VERSION="0.8.4" NOMAD_VERSION="0.5.6" VAULT_VERSION="0.7.3" packer build hashistack.json
```

---

## consul
Contains Consul specific installation scripts, configuration files.  Also has Packer templates specific to Consul usage.

Example Consul build command:

```
AWS_REGION="us-west-1" PACKER_ENVIRONMENT="production" CONSUL_VERSION="0.8.4" packer build consul.json
```

---

## nomad  
Contains Nomad specific installation scripts, configuration files.  Also has Packer templates specific to Nomad usage.


Example Nomad (including Consul) build command:

```
AWS_REGION="us-west-1" PACKER_ENVIRONMENT="production" NOMAD_VERSION="0.5.6" CONSUL_VERSION="0.8.4" packer build nomad.json
```

---

## vault    
Contains Vault specific installation scripts, configuration files.  Also has Packer templates specific to Vault usage.

Example Vault (including Consul) build command:

```
AWS_REGION="us-west-1" PACKER_ENVIRONMENT="production" VAULT_VERSION="0.7.3" CONSUL_VERSION="0.8.4" packer build vault.json
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
