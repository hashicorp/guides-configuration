require 'spec_helper'

describe file('/usr/local/bin/vault') do
  it { should be_file }
  it { should be_executable }
end

describe file('/usr/local/bin/consul') do
  it { should be_file }
  it { should be_executable }
end

describe command('/sbin/getcap $(readlink -f $(which vault))') do
  its(:stdout) { should match (/cap_ipc_lock\+ep/) }
  its(:exit_status) { should eq 0 }
end

describe service('vault') do
  it { should be_enabled }
  it { should be_running }
end

describe user('vault') do
  it { should exist }
end

describe file('/etc/vault.d') do
  it { should be_directory }
end

describe file('/opt/vault/data') do
  it { should be_directory }
end

describe file('/opt/vault/tls') do
  it { should be_directory }
end

describe command('curl http://localhost:8200/v1/sys/health -sL -w "%{http_code}\\n" -o /dev/null') do
  its(:stdout) { should match (/200/) }
end
