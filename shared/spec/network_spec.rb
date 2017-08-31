require 'spec_helper'
if host_inventory['ec2']['ami-id']
  describe interface('eth0') do
    it { should be_up }
  end
end
