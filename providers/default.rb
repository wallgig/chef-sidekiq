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

def whyrun_supported?
  true
end

use_inline_resources if defined?(use_inline_resources)

action :create do
  Chef::Log.info("Creating #{new_resource.name} at #{new_resource.sidekiq_config}") unless sidekiq_config_exist?
  template_variables = {}
  %w(
    name
    queues
    verbose
    concurrency
    processes
    timeout
    rails_env
    owner
    group
    pidfile
    logfile
    rails_env
    ).each do |a|
    template_variables[a.to_sym] = new_resource.send(a)
  end

  converge_by("Create sidekiq dir #{new_resource.sidekiq_dir}") do
    directory new_resource.sidekiq_dir do
      owner new_resource.owner if new_resource.owner
      group new_resource.group if new_resource.group
      mode '0755'
      recursive true
      action :create
    end
  end

  converge_by("Create working dir #{new_resource.working_dir}") do
    directory new_resource.working_dir do
      owner new_resource.owner if new_resource.owner
      group new_resource.group if new_resource.group
      mode '0755'
      recursive true
      action :create
    end
  end

  converge_by("Render sidekiq config template #{new_resource.sidekiq_config}") do
    template new_resource.sidekiq_config do
      source new_resource.template
      cookbook new_resource.cookbook
      mode '0644'
      owner new_resource.owner if new_resource.owner
      group new_resource.group if new_resource.group
      variables template_variables
    end
  end

  converge_by("Create runit script #{new_resource.name}") do
    run_context.include_recipe 'runit'
    runit_service "sidekiq-#{new_resource.name}" do
      default_logger true
      run_template_name 'sidekiq'
      log_template_name 'sidekiq'
      cookbook 'sidekiq'
      owner new_resource.owner if new_resource.owner
      group new_resource.group if new_resource.group
      options(
        :pidfile => new_resource.pidfile,
        :sidekiq_config => new_resource.sidekiq_config,
        :working_dir => new_resource.working_dir,
        :bundle_exec => new_resource.bundle_exec,
        :rails_env => new_resource.rails_env,
        :owner => new_resource.owner,
        :group => new_resource.group
      )
    end
  end
end

action :delete do
  if sidekiq_config_exist?
    if ::File.writable?(new_resource.sidekiq_config)
      Chef::Log.info("Deleting #{new_resource.name} at #{new_resource.sidekiq_config}")
      ::File.delete(new_resource.sidekiq_config)
      new_resource.updated_by_last_action(true)
    else
      fail "Cannot delete #{new_resource.name} at #{new_resource.sidekiq_config}!"
    end
  end
end

private

def sidekiq_config_exist?
  ::File.exist?(new_resource.sidekiq_config)
end
