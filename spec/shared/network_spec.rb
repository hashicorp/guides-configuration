# Copyright IBM Corp. 2017, 2026

if !host_inventory['user']['vagrant']
  describe interface('eth0') do
    it { should be_up }
  end
end
