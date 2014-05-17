require 'spec_helper'

describe command('ls /srv/apps/railstest/shared/sidekiq/') do
  it { should return_stdout /No such file or directory/ }
end

describe service('sidekiq-railstest') do
  it { should_not be_enabled }
end
