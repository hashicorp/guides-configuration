#!/bin/bash

echo "Running"

sudo gem install bundler --no-ri --no-rdoc
sudo /usr/local/bin/bundle install --system

echo "Complete"
