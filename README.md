# Sidekiq [![Build Status](https://secure.travis-ci.org/wallgig/chef-sidekiq.png)](http://travis-ci.org/wallgig/chef-sidekiq)

Chef cookbook for [sidekiq](http://sidekiq.org/).

# Requirements

## Chef

Tested on chef 11

## Cookbooks

The following cookbooks are required:

* [runit](http://github.com/hw-cookbooks/runit)

## Resources/Providers

### sidekiq

This generates a sidekiq configuration and creates a [runit](http://smarden.org/runit/) service. This cookbooks expects that you are deploying with
capistrano, but should be flexible enough to tune for whatever you need.

### Actions

* :create create a named puma configuration, and service.
* :delete disable a named puma service, and deletes the puma directory.

### Examples

```ruby
sidekiq 'example.com' do
  concurrency 2
  processes 2
  queues 'job-queue' => 5, 'other-queue' => 1
end
```

```ruby
sidekiq 'example.com' do
  concurrency 2
  processes 2
  queues 'job-queue' => 5, 'other-queue' => 1
  directory '/srv/www/myapp'
  puma_dir '/srv/www/myapp/puma'
end
```

``ruby
sidekiq 'example.com' do
  action :delete
end
``

## Attributes
<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Default Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>name</td>
      <td><b>Name attribute:</b> The name of the sidekiq instance.</td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>queues</td>
      <td>A hash of sidekiq queues</td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>verbose</td>
      <td>Should the sidekiq daemon be verbose, useful for debugging.</td>
      <td><code>false</code></td>
    </tr>
    <tr>
      <td>concurrency</td>
      <td>Number of concurrent sidekiq processes</td>
      <td><code>25</code></td>
    </tr>
    <tr>
      <td>processes</td>
      <td>The number of processes</td>
      <td><code>1</code></td>
    </tr>
    <tr>
      <td>timeout</td>
      <td>Timeout for sidekiq jobs, in seconds</td>
      <td><code>30</code></td>
    </tr>
    <tr>
      <td>rails_env</td>
      <td>Your rails environment</td>
      <td><code>production</code></td>
    </tr>
    <tr>
      <td>bundle_exec</td>
      <td>Should bundle exec be used to start sidekiq</td>
      <td><code>true</code></td>
    </tr>
    <tr>
      <td>owner</td>
      <td>The user of the sidekiq process</td>
      <td><code>www-data</code></td>
    </tr>
    <tr>
      <td>group</td>
      <td>The group of the sidekiq process</td>
      <td><code>www-data</code></td>
    </tr>
   </tr>
  </tbody>
</table>

## Platforms

* Debian 7+
* Ubuntu 13.10+

# Issues

Find a bug? Want a feature? Submit an [issue here](http://github.com/wallgig/chef-sidekiq/issues). Patches welcome!

# Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

# LICENSE & AUTHORS #

* Authors:: Greg Fitzgerald (<greg@gregf.org>)

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
