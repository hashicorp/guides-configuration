require 'spec_helper'

describe file('/usr/local/bin/nomad') do
  it { should be_file }
  it { should be_executable }
end

describe service('nomad') do
  it { should be_running   }
end

describe port(4646) do
  it { should be_listening.with('tcp') }
end
