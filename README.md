# Global [![Build Status](https://travis-ci.org/railsware/global.png)](https://travis-ci.org/railsware/global) [![Code Climate](https://codeclimate.com/github/railsware/global.png)](https://codeclimate.com/github/railsware/global)

The 'global' gem provides accessor methods for your configuration data and share configuration across backend and frontend. The data is stored in yaml files.

## Installation

Add to Gemfile:

```ruby
gem 'global'
```

## Configuration

```ruby
> Global.environment = "YOUR_ENV_HERE"
> Global.config_directory = "PATH_TO_DIRECTORY_WITH_FILES"
```

Or you can use `configure` block:

```ruby
Global.configure do |config|
  config.environment = "YOUR_ENV_HERE"
  config.config_directory = "PATH_TO_DIRECTORY_WITH_FILES"
end
```

For rails put initialization into `config/initializers/global.rb`

```ruby
Global.configure do |config|
  config.environment = Rails.env.to_s
  config.config_directory = Rails.root.join('config/global').to_s
end
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

## JavaScript in Rails support

### Configuration

```ruby
Global.configure do |config|
  config.namespace = "JAVASCRIPT_OBJECT_NAME" # default Global
  config.except = ["LIST_OF_FILES_TO_EXCLUDE_ON_FRONT_END"] # default :all
  config.only = ["LIST_OF_FILES_TO_INCLUDE_ON_FRONT_END"] # default []
end
```
By default all files are excluded due to security reasons. Don't include files which contain protected information like api keys or credentials. 

Require global file in `application.js`:

``` js
/*
= require global-js
*/
```

### Usage

Config file example `global/hosts.yml`:

```yml
development:
  web: localhost
  api: api.localhost
production:
  web: myhost.com
  api: api.myhost.com
```
After that in development environment we have:

``` js
Global.hosts.web
=> "localhost"
```

And in production: 

``` js
Global.hosts.web
=> "myhost.com"
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

Copyright (c) Railsware LLC. See LICENSE.txt for further details.

