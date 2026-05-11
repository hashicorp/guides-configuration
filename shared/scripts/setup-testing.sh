#!/bin/bash
# Copyright IBM Corp. 2017, 2026


echo "Running"

sudo gem install bundler --no-ri --no-rdoc
sudo /usr/local/bin/bundle install --system

echo "Complete"
