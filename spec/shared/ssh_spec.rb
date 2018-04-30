describe service('sshd') do
  it { should be_enabled }
end

if host_inventory['ec2']['ami-id']
  describe service('sshd') do
    it { should be_running }
  end
end
