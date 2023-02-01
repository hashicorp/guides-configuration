# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

describe package('ntp') do
  it { should be_installed }
end
  
describe service('ntpd'), :if => os[:family] == 'redhat' do
  it { should be_enabled   }
  it { should be_running   }
end
  
describe service('ntp'), :if => os[:family] == 'debian' do
  it { should be_enabled   }
  it { should be_running   }
end
