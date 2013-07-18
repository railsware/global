# global [![Build Status](https://travis-ci.org/paladiy/global.png)](https://travis-ci.org/paladiy/global) [![Code Climate](https://codeclimate.com/github/paladiy/global.png)](https://codeclimate.com/github/paladiy/global)

## Description

Global provides accessors methods to your configuration which is stored in yaml files.

## Instalation

```ruby
gem 'global'
```

## Configuration

```ruby
> Global.environment = "YOUR_ENV_HERE"
> Global.config_directory = "PATH_TO_DIRECTORY_WITH_FILES"
```

##Usage

#### Loading configuration from: `PATH_TO_DIRECTORY_WITH_FILES/hosts.yml`

```ruby
> Global.hosts
=> { "api" => "api.localhost.dev", "app" => "localhost.dev" }
> Global.hosts.api
=> { "api" => "api.localhost.dev" }
```

#### Loading recursive from: `PATH_TO_DIRECTORY_WITH_FILES/sites/api.yml`

```ruby
> Global.sites.api
=> { "host" => "api.localhost.dev", "port" => 3000 }
> Global.sites.api.host
=> "api.localhost.dev"
```

## Contributing to global

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2013 paladiy. See LICENSE.txt for
further details.

