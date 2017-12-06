require 'spec_helper'

describe file('/usr/local/bin/vault') do
  it { should be_file }
  it { should be_executable }
end

describe file('/usr/local/bin/consul') do
  it { should be_file }
  it { should be_executable }
end

describe command('/sbin/getcap /usr/local/bin/vault') do
  its(:stdout) { should match /cap_ipc_lock\+ep/ }
  its(:exit_status) { should eq 0 }
end

describe service('vault') do
  it { should be_enabled }
  it { should be_running }
end

describe file('/etc/vault.d') do
  it { should be_directory }
end

describe user('vault') do
  it { should exist }
end

file('/etc/vault.d/vault-consul.hcl') do
  it { should exist }
  its(:content) { should match /127.0.0.1:8500/ }
  its(:content) { should match /path/ }
  it { should be_readable.by('vault') }
end

file('/etc/vault.d/vault-no-tls.hcl') do
  it { should exist }
  its(:content) { should match /tls_disable = 1/ }
  its(:content) { should match /0.0.0.0:8200/ }
  it { should be_readable_by('vault') }
end

describe command('curl http://localhost:8200/v1/sys/health -sL -w "%{http_code}\\n" -o /dev/null') do
  its(:stdout) { should match /501/ }
end
