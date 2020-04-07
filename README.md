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
> Global.yaml_whitelist_classes = [] # optional configuration
```

Or you can use `configure` block:

```ruby
Global.configure do |config|
  config.environment = "YOUR_ENV_HERE"
  config.config_directory = "PATH_TO_DIRECTORY_WITH_FILES"
  config.yaml_whitelist_classes = [] # optional configuration
end
```

For rails put initialization into `config/initializers/global.rb`

```ruby
Global.configure do |config|
  config.environment = Rails.env.to_s
  config.config_directory = Rails.root.join('config', 'global').to_s
  config.yaml_whitelist_classes = [] # optional configuration
end
```

The `yaml_whitelist_classes` configuration allows you to deserialize other classes from your `.yml`

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

#### Deserialize other classes from `.yml`

Config file `config/global/validations.yml`:

```yml
default:
  regexp:
    email: !ruby/regexp /.@.+\../
```

Ensure that `Regexp` is included in the `yaml_whitelist_classes` array

```ruby
Global.validations.regexp.email === 'mail@example.com'
=> true
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

### Environment files

Config file `global/aws.yml` with:
```yml
:default:
  activated: false

staging:
  activated: true
  api_key: 'nothing'

```

And file `global/aws.production.yml` with:
```yml
:activated: true
:api_key: 'some api key'
:api_secret: 'some secret'

```

Provide such configuration on `Global.environment = 'production'` environment:

```ruby
> Global.aws.activated
=> true
> Global.aws.api_key
=> 'some api key'
> Global.aws.api_secret
=> 'some secret'
```

**Warning**: files with dot(s) in name will be skipped by Global (except this env files).

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

## Rails Webpacker usage

Add in `package.json` file `js-yaml` npm package (use command `yarn add js-yaml`).

Next create file `config/webpacker/global/index.js` with content:

```js
const yaml = require('js-yaml')
const fs = require('fs')
const path = require('path')

const FILE_ENV_SPLIT = '.'
const YAML_EXT = '.yml'

let globalConfig = {
  environment: null,
  configDirectory: null
}

const globalConfigure = (options = {}) => {
  globalConfig = Object.assign({}, globalConfig, options)
}

const getGlobalConfig = (key) => {
  let config = {}
  const filename = path.join(globalConfig.configDirectory, `${key}${YAML_EXT}`)
  if (fs.existsSync(filename)) {
    const configurations = yaml.safeLoad(fs.readFileSync(filename, 'utf8'))
    config = Object.assign({}, config, configurations['default'] || {})
    config = Object.assign({}, config, configurations[globalConfig.environment] || {})

    const envFilename = path.join(globalConfig.configDirectory, `${key}${FILE_ENV_SPLIT}${globalConfig.environment}${YAML_EXT}`)
    if (fs.existsSync(envFilename)) {
      const envConfigurations = yaml.safeLoad(fs.readFileSync(envFilename, 'utf8'))
      config = Object.assign({}, config, envConfigurations || {})
    }
  }
  return config
}

module.exports = {
  globalConfigure,
  getGlobalConfig
}
```

After this modify file `config/webpacker/environment.js`:

```js
const path = require('path')
const {environment} = require('@rails/webpacker')
const {globalConfigure, getGlobalConfig} = require('./global')

globalConfigure({
  environment: process.env.RAILS_ENV || 'development',
  configDirectory: path.resolve(__dirname, '../global')
})

const sentrySettings = getGlobalConfig('sentry')

environment.plugins.prepend('Environment', new webpack.EnvironmentPlugin({
  GLOBAL_SENTRY_ENABLED: sentrySettings.enabled,
  GLOBAL_SENTRY_JS_KEY: sentrySettings.js,
  ...
}))

...

module.exports = environment
```

Now you can use this variable in you code:

```js
import {init} from '@sentry/browser'

if (process.env.GLOBAL_SENTRY_ENABLED) {
  init({
    dsn: process.env.GLOBAL_SENTRY_JS_KEY
  })
}
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
