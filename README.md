# Intro
This repo contains Packer templates used for modules in hashicorp-modules

---

## hashi-stack  
Contains provider specific templates that installs HashiCorp software on a single node (Consul, Nomad, Vault, consul-template and envconsul).

---

## consul
Contains Consul specific installation scripts, configuration files.  Also has Packer templates specific to Consul usage.

Example Consul build command:

```
AWS_REGION="us-west-1" PACKER_ENVIRONMENT="Test" VCS_NAME="Dan Brown" CONSUL_VERSION="0.8.3" packer build consul-server.json
```

---

## nomad  
Contains Nomad specific installation scripts, configuration files.  Also has Packer templates specific to Nomad usage.


Example Nomad (including Consul) build command:

```
AWS_REGION="us-west-1" PACKER_ENVIRONMENT="Test" VCS_NAME="Dan Brown" NOMAD_VERSION="0.5.6" CONSUL_VERSION="0.8.3" packer build nomad-server.json
```

---

## vault    
Contains Vault specific installation scripts, configuration files.  Also has Packer templates specific to Vault usage.

Example Vault (including Consul) build command:

```
AWS_REGION="us-west-1" PACKER_ENVIRONMENT="Test" VCS_NAME="Dan Brown" VAULT_VERSION="0.7.2" CONSUL_VERSION="0.8.3" packer build vault-server.json
```
