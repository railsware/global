# global [![Build Status](https://travis-ci.org/railsware/global.png)](https://travis-ci.org/railsware/global) [![Code Climate](https://codeclimate.com/github/railsware/global.png)](https://codeclimate.com/github/railsware/global)

## Description

The 'global' gem provides accessor methods for your configuration data. The data is stored in yaml files.

## Installation

```ruby
gem 'global'
```

## Configuration

```ruby
> Global.environment = "YOUR_ENV_HERE"
> Global.config_directory = "PATH_TO_DIRECTORY_WITH_FILES"
```

For rails put initialization into `config/initializers/global.rb`

```ruby
Global.environment = Rails.env.to_s
Global.config_directory = Rails.root.join('config/global').to_s
```

## Usage

### General

Config file `config/global/hosts.yml`:

```yml
test:
  web: localhost
  api: api.localhost
development:
  web: localhost
  api: api.localhost
production:
  web: myhost.com
  api: api.myhost.com
```

In the development environment we now have:

```ruby
> Global.hosts
=> { "api" => "api.localhost", "web" => "localhost" }
> Global.hosts.api
=> "api.localhost"
```

### Namespacing

Config file `config/global/web/basic_auth.yml` with:

```yml
test:
  username: test_user
  password: secret
development:
  username: development_user
  password: secret
production:
  username: production_user
  password: supersecret
```

After that in development environment we have:

```ruby
> Global.web.basic_auth
=> { "username" => "development_user", "password" => "secret" }
> Global.web.basic_auth.username
=> "development_user"
```

### Default section

Config file example:

```yml
default:
  web: localhost
  api: api.localhost
production:
  web: myhost.com
  api: api.myhost.com
```

Data from the default section is used until it's overridden in a specific environment.

### Nested configurations

Config file `global/nested.yml` with:
```yml
test:
  group:
    key: "test value"
development:
  group:
    key: "development value"
production:
  group:
    key: "production value"
```

Nested options can then be accessed as follows: 

```ruby
> Global.nested.group.key
=> "development value"
```

### ERB support

Config file `global/file_name.yml` with:

```yml
test:
  key: <%=1+1%>
development:
  key: <%=2+2%>
production:
  key: <%=3+3%>
```

As a result, in the development environment we have:

```ruby
> Global.file_name.key
=> 4
```

### Reload configuration data

```ruby
> Global.reload!
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

Copyright (c) 2013 Railsware LLC. See LICENSE.txt for
further details.

