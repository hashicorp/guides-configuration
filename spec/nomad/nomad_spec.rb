require 'spec_helper'

describe file('/usr/local/bin/nomad') do
  it { should be_file }
  it { should be_executable }
end

describe service('nomad') do
  it { should be_enabled }
  it { should be_running }
end

describe file('/etc/nomad.d') do
  it { should be_directory }
end

describe file('/opt/nomad/data') do
  it { should be_directory }
end

describe file('/opt/nomad/tls') do
  it { should be_directory }
end

describe command('curl http://localhost:4646/v1/status/leader -sL -w "%{http_code}\\n" -o /dev/null'), :if => os[:family] == 'redhat' do
  its(:stdout) { should match (/200/) }
end

