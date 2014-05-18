require 'spec_helper'

describe file('/srv/apps/railstest/shared/sidekiq/railstest.yml') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'www-data' }
  it { should be_grouped_into 'www-data' }
  it { should contain '---
:verbose: false
:pidfile: /srv/apps/railstest/shared/sidekiq/railstest.pid
:logfile: /srv/apps/railstest/shared/sidekiq/railstest.log
:concurrency: 2
:processes: 2
:timeout: 30
:queues:
  - [job-queue, 5]
  - [other-queue, 1]'}
end

describe file('/srv/apps/railstest/shared/sidekiq/railstest.pid') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'www-data' }
  it { should be_grouped_into 'www-data' }
end

describe file('/srv/apps/railstest/shared/sidekiq/railstest.log') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'www-data' }
  it { should be_grouped_into 'www-data' }
end

describe service('sidekiq-railstest') do
  it { should be_running }
end
