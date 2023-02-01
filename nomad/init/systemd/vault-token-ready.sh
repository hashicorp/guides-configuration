#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


set -e
set -o pipefail

function waitForVaultToken() {
  local path=$1

  while [ ! -s "${path}" ] ; do
    echo "Waiting for file..."
    sleep 1
  done

  echo "File found."
}

waitForVaultToken "/secrets/nomad-server-token"
