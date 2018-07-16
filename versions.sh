#!/bin/bash

# X.Y.Z (e.g. 0.12.3)
export PACKER_VERSION="1.1.3"

# X.Y.Z (e.g. 0.10.0)
export TERRAFORM_VERSION="0.11.1"

## DON'T FORGET TO UPDATE the _VERSIONS env vars
# _and_ README with any product version bumps below

# Production release: X.Y.Z (e.g. 0.1.0)
# Release candidate: X.Y.Z-rcX (e.g. 0.1.0-rc1)
# Beta release: X.Y.Z-betaX (e.g. 0.1.0-beta1)
# Development branch: X.Y.Z-f-branch (e.g. 0.1.0-f-branch)
export RELEASE_VERSION="0.1.1"

# X.Y.Z or X.Y.Z-ent for Enterprise binary (e.g. 1.0.6 or 1.0.6-ent)
export CONSUL_VERSION="1.2.0-ent"

# X.Y.Z or X.Y.Z-ent for Enterprise binary (e.g. 0.10.0 or 0.10.0-ent)
export VAULT_VERSION="0.10.3-ent"

# X.Y.Z or X.Y.Z-ent for Enterprise binary (e.g. 0.8.0 or 0.8.0-ent)
export NOMAD_VERSION="0.8.4-ent"

# The below are aggregate lists of product versions to be published. Any
# time a product version above is updated, that new version _must_ be
# added to the appropriate list below to be published. Each *_VERSIONS list
# _must_ have the same number of items. If a product isn't being updated
# to a newer version, just duplicate the existing version to maintain an
# equivalent number of items in each of these lists. These lists should match
# https://github.com/hashicorp/guides-configuration#hashistack-version-tables.
# Every time a product version is updated, the RELEASE_VERSION must be bumped
# as well.
export RELEASE_VERSIONS='release_versions=["0.1.0","0.1.1",]'
export CONSUL_VERSIONS='consul_versions=["1.2.0","1.2.0-ent",]'
export VAULT_VERSIONS='vault_versions=["0.10.3","0.10.3-ent",]'
export NOMAD_VERSIONS='nomad_versions=["0.8.4","0.8.4-ent",]'

# Force build or run on feature branch
export RUN_BUILD=false
export RUN_PUBLISH=false
