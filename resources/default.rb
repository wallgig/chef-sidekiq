# Author:: Greg Fitzgerald (greg@gregf.org)
# Copyright:: Copyright (c) 2014 Greg Fitzgerald
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

actions :create, :delete
default_action :create

attribute :name, :kind_of => String, :name_attribute => true, :required => true
attribute :template, :kind_of => String, :default => 'sidekiq.yml.erb'
attribute :cookbook, :kind_of => String, :default => 'sidekiq'
attribute :queues, :kind_of => Hash, :required => true
attribute :verbose, :kind_of => [TrueClass, FalseClass], :default => false
attribute :concurrency, :kind_of => Integer, :default => 1
attribute :processes, :kind_of => Integer, :default => 1
attribute :timeout, :kind_of => Integer, :default => 30
attribute :rails_env, :kind_of => String, :default => 'production'
attribute :bundle_exec, :kind_of => [TrueClass, FalseClass], :default => true
attribute :owner, :regex => Chef::Config[:user_valid_regex], :default => 'www-data'
attribute :group, :regex => Chef::Config[:group_valid_regex], :default => 'www-data'
attribute :directory, :kind_of => [String, NilClass], :default => nil
attribute :working_dir, :kind_of => [String, NilClass], :default => nil
attribute :sidekiq_dir, :kind_of => [String, NilClass], :default => nil
attribute :sidekiq_config, :kind_of => [String, NilClass], :default => nil
attribute :pidfile, :kind_of => [String, NilClass], :default => nil
attribute :logfile, :kind_of => [String, NilClass], :default => nil

def initialize(*args)
  super
  @action = :create
end
