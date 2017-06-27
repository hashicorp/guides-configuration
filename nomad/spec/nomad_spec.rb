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
  its(:content) { should match /127.0.0.1:8200/ }
end

file('/etc/nomad.d/nomad-client.hcl') do
  it { should exist }
  its(:content) { should match /tls_disable = 1/ }
end

file('/opt/nomad/data') do
  it { should be_directory }
end

describe port(4646) do
  it { should be_listening.with('tcp') }
end

describe http_get(8500, 'localhost', '/v1/status/leader') do
  its(:status) { should eq 200 }
end


