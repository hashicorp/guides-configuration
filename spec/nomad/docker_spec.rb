require 'spec_helper'

describe command('docker --version') do
  its(:exit_status) { should eq 0 }
end
