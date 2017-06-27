require 'spec_helper'

describe file('/usr/local/bin/consul') do
  it { should be_file }
  it { should be_executable }
end

describe service('consul') do
  it { should be_enabled   }
  it { should be_running   }
end

describe file('/etc/consul.d') do
  it { should be_directory }
end

describe user('consul') do
  it { should exist }
end

file('/etc/consul.d/consul.hcl') do
  it { should exist }
  its(:content) { should match /127.0.0.1:8200/ }
  it { should be_readable.by('consul') }
end

file('/etc/consul.d/consul-server.hcl') do
  it { should exist }
  its(:content) { should match /tls_disable = 1/ }
  it { should be_readable_by('consul') }
end

file('/opt/consul/data') do
  it { should be_directory }
  it { should be_writable_by('consul') }
end

describe port(8500) do
  it { should be_listening.with('tcp') }
end

describe http_get(8500, 'localhost', '/v1/status/leader') do
  its(:status) { should eq 200 }
end


