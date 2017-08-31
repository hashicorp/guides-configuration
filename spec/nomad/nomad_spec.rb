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

file('/opt/nomad/data') do
  it { should be_directory }
end

file('/etc/nomad.d/nomad-client.hcl.example') do
  it { should exist }
  its(:content) { should match (/client/) }
  its(:content) { should match (/enabled         = true/) }
  its(:content) { should match (/client_max_port = 15000/) }
  its(:content) { should match (/options/) }
  its(:content) { should match (/"docker.cleanup.image"   = "0"/) }
  its(:content) { should match (/"driver.raw_exec.enable" = "1"/) }
end

file('/etc/nomad.d/nomad-consul.hcl.example') do
  it { should exist }
  its(:content) { should match (/consul/) }
  its(:content) { should match (/address        = "127.0.0.1:8500"/) }
  its(:content) { should match (/auto_advertise = true/) }
  its(:content) { should match (/client_service_name = "nomad-client"/) }
  its(:content) { should match (/client_auto_join    = true/) }
  its(:content) { should match (/server_service_name = "nomad-server"/) }
  its(:content) { should match (/server_auto_join    = true/) }
end

file('/etc/nomad.d/nomad-default.hcl.example') do
  it { should exist }
  its(:content) { should match (/data_dir     = "\/opt\/nomad\/data"/) }
  its(:content) { should match (/log_level    = "INFO"/) }
  its(:content) { should match (/enable_debug = true/) }
end

file('/etc/nomad.d/nomad-server.hcl.example') do
  it { should exist }
  its(:content) { should match (/server/) }
  its(:content) { should match (/enabled          = true/) }
  its(:content) { should match (/bootstrap_expect = 1/) }
  its(:content) { should match (/heartbeat_grace  = "30s"/) }
end

describe command('curl http://localhost:4646/v1/status/leader -sL -w "%{http_code}\\n" -o /dev/null'), :if => os[:family] == 'redhat' do
  its(:stdout) { should match /200/ }
end

