require 'spec_helper'

describe service('ssh') do
  it { should be_enabled }
  it { should be_running }
end
