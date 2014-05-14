#
# Cookbook Name:: sidekiq-test
# Recipe:: default
#

include_recipe 'build-essential'

package 'ruby1.9.1-full'
package 'ruby1.9.1-dev'
package 'libssl-dev'
package 'libsqlite3-dev'

user 'www-data' do
  home '/srv/app'
end

group 'www-data' do
  members 'www-data'
end

directory '/srv/apps/railstest/releases/' do
  owner 'www-data'
  group 'www-data'
  mode '0755'
  recursive true
end

git '/srv/apps/railstest/releases' do
  repository 'https://github.com/gregf/testapp.git'
  revision 'master'
  user 'www-data'
  group 'www-data'
  action :sync
end

link '/srv/apps/railstest/current' do
  to '/srv/apps/railstest/releases'
end

gem_package 'bundler'

directory '/srv/apps/railstest' do
  owner 'www-data'
  group 'www-data'
  mode '0755'
  recursive true
  action :create
end

bash 'bundle install' do
  user 'www-data'
  cwd '/srv/apps/railstest/current'
  code <<-EOH
  bundle install --jobs 2 --path vendor/bundle
  EOH
end

include_recipe 'sidekiq'

sidekiq 'railstest' do
  concurrency 2
  processes 2
  queues 'job-queue' => 5, 'other-queue' => 1
end
