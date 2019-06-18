#!/bin/bash

# X.Y.Z (e.g. 0.12.3)
export PACKER_VERSION="1.4.1"

# X.Y.Z (e.g. 0.11.1)
export TERRAFORM_VERSION="0.12.2"

## DON'T FORGET TO UPDATE the _VERSIONS env vars
# _and_ README with any product version bumps below

# Production release: X.Y.Z (e.g. 0.1.0)
# Release candidate: X.Y.Z-rcX (e.g. 0.1.0-rc1)
# Beta release: X.Y.Z-betaX (e.g. 0.1.0-beta1)
# Development branch: X.Y.Z-f-branch (e.g. 0.1.0-f-branch)
export RELEASE_VERSION="1.0.0"

# X.Y.Z or X.Y.Z-ent for Enterprise binary (e.g. 1.0.6 or 1.0.6-ent)
export CONSUL_VERSION="1.5.1"

# X.Y.Z or X.Y.Z-ent for Enterprise binary (e.g. 0.10.0 or 0.10.0-ent)
export VAULT_VERSION="1.1.3"

# X.Y.Z or X.Y.Z-ent for Enterprise binary (e.g. 0.8.0 or 0.8.0-ent)
export NOMAD_VERSION="0.9.3"

# The below are aggregate lists of product versions to be published. Any
# time a product version above is updated, that new version _must_ be
# added to the appropriate list below to be published. Each *_VERSIONS list
# _must_ have the same number of items.

# If a product _isn't_ being updated to a newer version, just duplicate the
# existing version to maintain an equivalent number of items in each of these
# lists. These lists should match https://github.com/hashicorp/guides-configuration#hashistack-version-tables.
#  Every time a product version is updated, the RELEASE_VERSION must be bumped
# as well.

# To make a `release_versions` images public, set the version map value to
# `true` or `false`. Enterprise images will _not_ be set to public even if
# `true` is set.
export RELEASE_VERSIONS='release_versions=[{"0.1.0"=true},{"0.1.1"=false},{"1.0.0"=false},]'
export CONSUL_VERSIONS='consul_versions=["1.2.3","1.2.3-ent","1.5.1",]'
export VAULT_VERSIONS='vault_versions=["0.11.3","0.11.3-ent","1.1.3",]'
export NOMAD_VERSIONS='nomad_versions=["0.8.6","0.8.6-ent","0.9.3",]'

# Force build or run on feature branch
export RUN_BUILD=false
export RUN_PUBLISH=false
