#!/bin/bash
set -x

echo "Running"

echo "Cleanup AWS install artifacts"
sudo rm -rf /var/lib/cloud/instances/*
sudo rm -f /root/.ssh/authorized_keys

echo "Complete"
