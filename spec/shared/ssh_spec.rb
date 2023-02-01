# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

describe service('sshd') do
  it { should be_enabled }
end

if host_inventory['ec2']['ami-id']
  describe service('sshd') do
    it { should be_running }
  end
end
