require 'spec_helper'

describe file('/usr/local/bin/nomad') do
  it { should be_file }
  it { should be_executable }
end

describe service('nomad') do
  it { should be_enabled   }
  it { should be_running   }
end

describe file('/etc/nomad.d') do
  it { should be_directory }
end

file('/etc/nomad.d/nomad-server.hcl') do
  it { should exist }
  its(:content) { should match /true/ }
end

file('/etc/nomad.d/nomad-client.hcl') do
  it { should exist }
  its(:content) { should match /true/ }
end

file('/etc/nomad.d/nomad-default.hcl') do
  it { should exist }
  its(:content) { should match /\/opt\/nomad\/data/ }
end

file('/etc/nomad.d/nomad-consul.hcl') do
  it { should exist }
  its(:content) { should match /127.0.0.1:8500/ }
  its(:content) { should match /auto_advertise = true/ }
  its(:content) { should match /client_auto_join    = true/ }
  its(:content) { should match /server_auto_join    = true/ }
end

file('/opt/nomad/data') do
  it { should be_directory }
end

describe command('curl http://localhost:4646/v1/status/leader -sL -w "%{http_code}\\n" -o /dev/null'), :if => os[:family] == 'redhat' do
  its(:stdout) { should match /200/ }
end

