# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

require 'spec_helper'

describe command('java -version') do
  its(:exit_status) { should eq 0 }
end
