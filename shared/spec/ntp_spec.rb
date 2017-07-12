require 'spec_helper'

describe package('ntp') do
  it { should be_installed }
end

describe service('ntpd'), :if => os[:family] == 'redhat' do
  it { should be_enabled   }
  it { should be_running   }
end

describe service('ntp'), :if => os[:family] == ['debian','ubuntu'] do
  it { should be_enabled   }
  it { should be_running   }
end
 