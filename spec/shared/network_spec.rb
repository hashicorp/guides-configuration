# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

if !host_inventory['user']['vagrant']
  describe interface('eth0') do
    it { should be_up }
  end
end
