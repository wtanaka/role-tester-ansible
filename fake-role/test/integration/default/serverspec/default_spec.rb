require 'serverspec'
set :backend, :exec

describe file('/tmp/fakerole.txt') do
  it { should exist }
  it { should be_file }
end
