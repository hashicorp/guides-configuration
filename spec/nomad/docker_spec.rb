require 'spec_helper'

describe command('docker --version'), :if => os[:family] == 'debian' do
  its(:exit_status) { should eq 0 }
end
