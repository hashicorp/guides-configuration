require 'spec_helper'

describe file('/usr/local/bin/consul') do
  it { should be_file }
  it { should be_executable }
end

describe service('consul') do
  it { should be_enabled }
  it { should be_running }
end

describe user('consul') do
  it { should exist }
end

describe file('/etc/consul.d') do
  it { should be_directory }
end

describe file('/opt/consul/data') do
  it { should be_directory }
end

describe file('/opt/consul/tls') do
  it { should be_directory }
end

describe command('curl http://localhost:8500/v1/status/leader -sL -w "%{http_code}\\n" -o /dev/null') do
  its(:stdout) { should match (/200/) }
end
