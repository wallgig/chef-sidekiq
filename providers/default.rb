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

def root_directory
  if new_resource.directory
    new_resource.directory
  else
    ::File.join('/srv/apps', new_resource.name)
  end
end

def working_dir
  if new_resource.working_dir
    new_resource.working_dir
  else
    ::File.join(root_directory, '/current')
  end
end

def sidekiq_dir
  if new_resource.sidekiq_dir
    new_resource.sidekiq_dir
  else
    ::File.join(root_directory, '/shared/sidekiq')
  end
end

def sidekiq_config
  if new_resource.sidekiq_config
    new_resource.sidekiq_config
  else
    ::File.join(sidekiq_dir, new_resource.name + '.yml')
  end
end

def pidfile
  if new_resource.pidfile
    new_resource.pidfile
  else
    ::File.join(sidekiq_dir, new_resource.name + '.pid')
  end
end

def logfile
  if new_resource.logfile
    new_resource.logfile
  else
    ::File.join(sidekiq_dir, new_resource.name + '.log')
  end
end

action :create do
  Chef::Log.info("Creating #{new_resource.name} at #{sidekiq_config}") unless sidekiq_config_exist?

  log_file = logfile

  converge_by("Create sidekiq dir #{new_resource.sidekiq_dir}") do
    directory sidekiq_dir do
      owner new_resource.owner if new_resource.owner
      group new_resource.group if new_resource.group
      mode '0755'
      recursive true
      action :create
    end
  end

  converge_by("Create working dir #{new_resource.working_dir}") do
    directory working_dir do
      owner new_resource.owner if new_resource.owner
      group new_resource.group if new_resource.group
      mode '0755'
      recursive true
      action :create
    end
  end

  converge_by("Render sidekiq config template #{sidekiq_config}") do
    template sidekiq_config do
      source new_resource.template
      cookbook new_resource.cookbook
      mode '0644'
      owner new_resource.owner if new_resource.owner
      group new_resource.group if new_resource.group
      variables(
        :name => new_resource.name,
        :queues => new_resource.queues,
        :verbose => new_resource.verbose,
        :concurrency => new_resource.concurrency,
        :processes => new_resource.processes,
        :timeout => new_resource.timeout,
        :rails_env => new_resource.rails_env,
        :owner => new_resource.owner,
        :group => new_resource.group,
        :pidfile => pidfile,
        :logfile => logfile
      )
      notifies :restart, "runit_service[sidekiq-#{new_resource.name}]", :delayed
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
        :pidfile => pidfile,
        :sidekiq_config => sidekiq_config,
        :working_dir => working_dir,
        :bundle_exec => new_resource.bundle_exec,
        :rails_env => new_resource.rails_env,
        :owner => new_resource.owner,
        :group => new_resource.group
      )
    end
  end

  converge_by("Create logroate config #{new_resource.name}") do
    run_context.include_recipe 'logrotate'
    logrotate_app "sidekiq-#{new_resource.name}" do
      cookbook 'logrotate'
      path log_file
      frequency 'daily'
      rotate 30
      size '5M'
      create    '644 root adm'
      options ['missingok', 'compress', 'delaycompress', 'notifempty', 'dateext']
      only_if { new_resource.logrotate }
    end
  end
end

action :delete do
  converge_by("Disabling sidekiq-#{new_resource.name}") do
    run_context.include_recipe 'runit'
    runit_service "sidekiq-#{new_resource.name}" do
      action :disable
    end
  end

  converge_by("Deleting sidekiq_dir #{sidekiq_dir}") do
    directory sidekiq_dir do
      recursive true
      action :delete
    end
  end
end

private

def sidekiq_config_exist?
  ::File.exist?(sidekiq_config)
end
