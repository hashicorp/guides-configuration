if !host_inventory['user']['vagrant']
  describe interface('eth0') do
    it { should be_up }
  end
end
