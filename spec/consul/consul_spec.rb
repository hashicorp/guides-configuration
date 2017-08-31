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

file('/opt/consul/data') do
  it { should be_directory }
  it { should be_writable_by('consul') }
  it { should be_readable_by('consul') }
end

file('/etc/consul.d/consul-default.json.example') do
  it { should exist }
  its(:content_as_json) { should include('advertise_addr' => '127.0.0.1') }
  its(:content_as_json) { should include('data_dir' => '/opt/consul/data') }
  its(:content_as_json) { should include('client_addr' => '0.0.0.0') }
  its(:content_as_json) { should include('log_level' => 'INFO') }
  its(:content_as_json) { should include('ui' => 'true') }
  it { should be_readable.by('consul') }
end

file('/etc/consul.d/consul-server.json.example') do
  it { should exist }
  its(:content_as_json) { should include('server' => 'true') }
  its(:content_as_json) { should include('bootstrap_expect' => '1') }
  its(:content_as_json) { should include('leave_on_terminate' => 'true') }
  it { should be_readable_by('consul') }
end

describe command('curl http://localhost:8500/v1/status/leader -sL -w "%{http_code}\\n" -o /dev/null') do
  its(:stdout) { should match (/200/) }
end
