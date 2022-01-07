# Global [![Runs linter and tests](https://github.com/railsware/global/actions/workflows/tests.yml/badge.svg?branch=master)](https://github.com/railsware/global/actions/workflows/tests.yml) [![Code Climate](https://codeclimate.com/github/railsware/global.png)](https://codeclimate.com/github/railsware/global)

The 'global' gem provides accessor methods for your configuration data and share configuration across backend and frontend.

The data can be stored in [YAML](https://yaml.org) files on disk, or in the [AWS SSM Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html).

## Installation

Add to Gemfile:

```ruby
gem 'global'
```

Refer to the documentation on your chosen backend class for other dependencies.

## Configuration

Refer to the documentation on your chosen backend class for configuration options.

```ruby
> Global.backend(:filesystem, environment: "YOUR_ENV_HERE", path: "PATH_TO_DIRECTORY_WITH_FILES")
```

Or you can use `configure` block:

```ruby
Global.configure do |config|
  config.backend :filesystem, environment: "YOUR_ENV_HERE", path: "PATH_TO_DIRECTORY_WITH_FILES"
  # set up multiple backends and have them merged together:
  config.backend :aws_parameter_store, prefix: '/prod/MyApp/'
  config.backend :gcp_secret_manager, prefix: 'prod-myapp-', project_id: 'example'
end
```

### Using multiple backends

Sometimes it is practical to store some configuration data on disk (and perhaps, commit it to source control), but
keep some other data in a secure remote location. Which is why you can use more than one backend with Global.

You can declare as many backends as you want; the configuration trees from the backends are deep-merged together,
so that the backend declared later overwrites specific keys in the backend declared prior:

```ruby
Global.configure do |config|
  config.backend :foo # loads tree { credentials: { hostname: 'api.com', username: 'dev', password: 'dev' } }
  config.backend :bar # loads tree { credentials: { username: 'xxx', password: 'yyy' } }
end

Global.credentials.hostname # => 'api.com'
Global.credentials.username # => 'xxx'
Global.credentials.password # => 'yyy'
```

For Rails, put initialization into `config/initializers/global.rb`.

There are some sensible defaults, check your backend class for documentation.

```ruby
Global.configure do |config|
  config.backend :filesystem
end
```

### Filesystem storage

The `yaml_whitelist_classes` configuration allows you to deserialize other classes from your `.yml`

### AWS Parameter Store

The `aws_options` configuration allows you to customize the AWS credentials and connection.

### Google Cloud Secret Manager

The `gcp_options` configuration allows you to customize the Google Cloud credentials and timeout.

## Usage

### Filesystem

For file `config/global/hosts.yml`:

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

#### Per-environment sections

You can define environment sections at the top level of every individual YAML file

For example, having a config file `config/global/web/basic_auth.yml` with:

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

You get the correct configuration in development

```ruby
> Global.web.basic_auth
=> { "username" => "development_user", "password" => "secret" }
> Global.web.basic_auth.username
=> "development_user"
```

#### Default section

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

#### Nested configurations

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

#### Environment files

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

#### ERB support

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

### AWS Parameter Store

Parameter Store is a secure configuration storage with at-rest encryption. Access is controlled through AWS IAM. You do not need to be hosted on AWS to use Parameter Store.

Refer to the [official documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) to set up the store.

Some steps you will need to follow:

- Allocate an AWS IAM role for your app.
- Create an IAM user for the role and pass credentials in standard AWS env vars (applications on Fargate get roles automatically).
- Choose a prefix for the parameters. By default, the prefix is `/environment_name/AppClassName/`. You can change it with backend parameters (prefer to use '/' as separator).
- Allow the role to read parameters from AWS SSM. Scope access by the prefix that you're going to use.
- If you will use encrypted parameters: create a KMS key and allow the role to decrypt using the key.
- Create parameters in Parameter Store. Use encryption for sensitive data like private keys and API credentials.

#### Usage with Go

You can reuse the same configuration in your Go services. For this, we developed a Go module that loads the same configuration tree into Go structs.

See [github.com/railsware/go-global](https://github.com/railsware/go-global) for further instructions.

#### Configuration examples

Backend setup:

```ruby
# in config/environments/development.rb
# you don't need to go to Parameter Store for dev machines
Global.backend(:filesystem)

# in config/environments/production.rb
# enterprise grade protection for your secrets
Global.backend(:aws_parameter_store, app_name: 'my_big_app')
```

Create parameters:

```
/production/my_big_app/basic_auth/username => "bill"
/production/my_big_app/basic_auth/password => "secret" # make sure to encrypt this one!
/production/my_big_app/api_endpoint => "https://api.myapp.com"
```

Get configuration in the app:

```ruby
# Encrypted parameters are automatically decrypted:
> Global.basic_auth.password
=> "secret"
> Global.api_endpoint
=> "https://api.myapp.com"
```

### Google Cloud Secret Manager

Google Cloud Secret Manager allows you to store, manage, and access secrets as binary blobs or text strings. With the appropriate permissions, you can view the contents of the secret.
Google Cloud Secret Manager works well for storing configuration information such as database passwords, API keys, or TLS certificates needed by an application at runtime.

Refer to the [official documentation](https://cloud.google.com/secret-manager/docs) to set up the secret manager.

Some steps you will need to follow:

- Choose a prefix for the secret key name. By default, the prefix is `environment_name-AppClassName-`. You can change it with backend parameters (prefer to use '-' as separator).

#### Configuration examples

Backend setup:

```ruby
# in config/environments/development.rb
# you don't need to go to Parameter Store for dev machines
Global.backend(:filesystem)

# in config/environments/production.rb
# enterprise grade protection for your secrets
Global.backend(:gcp_secret_manager, prefix: 'prod-myapp-', project_id: 'example')
```

Create secrets:

```
prod-myapp-basic_auth-username => "bill"
prod-myapp-basic_auth-password => "secret"
prod-myapp-api_endpoint => "https://api.myapp.com"
```

Get configuration in the app:

```ruby
# Encrypted parameters are automatically decrypted:
> Global.basic_auth.password
=> "secret"
> Global.api_endpoint
=> "https://api.myapp.com"
```

### Reload configuration data

```ruby
> Global.reload!
```

## Using YAML configuration files with Rails Webpacker

If you use the `:filesystem` backend, you can reuse the same configuration files on the frontend:

Add [js-yaml](https://www.npmjs.com/package/js-yaml) npm package to `package.json` (use command `yarn add js-yaml`).

Then create a file at `config/webpacker/global/index.js` with the following:

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

After this, modify file `config/webpacker/environment.js`:

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

Now you can use these `process.env` keys in your code:

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

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/railsware/global/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Global project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/railsware/global/blob/master/CODE_OF_CONDUCT.md).
