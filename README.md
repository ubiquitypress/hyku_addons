# HykuAddons
Code: [![CircleCI](https://circleci.com/gh/ubiquitypress/hyku_addons.svg?style=svg)](https://circleci.com/gh/ubiquitypress/hyku_addons)
[![Code Climate](https://codeclimate.com/github/ubiquitypress/hyku_addons/badges/gpa.svg)](https://codeclimate.com/github/ubiquitypress/hyku_addons)


Docs: [![Contribution Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./CONTRIBUTING.md)
[![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)

Jump in: [![Slack Status](http://slack.samvera.org/badge.svg)](http://slack.samvera.org/)


HykuAddons is a collection of customizations made to Hyku for Ubiquity Press's implementation.  It is highly opinionated and idiosyncratic so feel free to look at it for inspiration but you probably don't want to use it.  Features that are generally useful will be split out of here into separate plugins.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'hyku_addons'
```

And then execute:
```bash
$ bundle
```

## How it works

### Application code
All code that would normally go under `app` in Hyku (controllers, mailers, helpers, jobs, models, etc.) still does in this engine.

### Views
Views provided by this engine are prepended to the view path so they take precedence over Hyku and Hyrax views.  To override a view from Hyku or Hyrax copy it to the same relative path within this engine then modify it.

### Routes
Routes added by this engine are declared in `config/routes.rb` just like a normal Rails application.  Normally an engine's routes are mounted in an application's `routes.rb` but this engine mounts them automatically during initialization to avoid the need of modifying any file in Hyku other than `Gemfile`.

If you need to reference a Hyku route using a route helper then you can access it through `main_app`.  If it is a Hyrax route then use `hyrax`.  For example:
```
  redirect_to main_app.new_user_registration_url
  redirect_to hyrax.dashboard_path
```

### Database Migrations
Migrations for database changes introduced by this engine are defined in `db/migrate` like any Rails application.  These get copied into Hyku during installation when the following in run:

```
bundle exec rails app:hyku_addons:install:migrations
```

These files are suffixed by the engine name for easy identification (e.g. `20200103172822_add_contact_email_to_sites.hyku_additions.rb`).  This command is safe to rerun and will only copy over missing migrations.  See https://edgeguides.rubyonrails.org/engines.html#engine-setup for more details.

To perform the migration you will need to scope the command as follows:

``
bundle exec rails db:migrate SCOPE=hyku_addons
```

Don't forget to run the test migations at the same time:

```
RAILS_ENV=test bundle exec rails db:migrate
```

If you get errors when performing the migration it might be because your schema is out of date. This means you wil need to manually add the version numbers to the `schema_migration` table inside the database.

For instance:

```
Caused by:
PG::DuplicateColumn: ERROR:  column "frontend_url" of relation "accounts" already exists
#...
/home/app/spec/internal_test_hyku/db/migrate/20210409153318_add_frontend_url_to_account.hyku_addons.rb:5:in `change'
#...
```

Use the following to insert the version into the migration table:

```
sql = "insert into schema_migrations (version) values ('20210409153318')"
ActiveRecord::Base.connection.execute(sql)
``

To manually connect to the postgres container, first connect to the `web` container and then:

```
psql --host db --port 5432 --user postgres --dbname hyku
```

Then enter the password from the `docker-compose.yml` POSTGRES_PASSWORD.


### Initializers
Initializers that should be run within Hyku can be added to `config/initializers` like in a Rails application.  They can also be added as `initializer` blocks within the `Engine` class, but that should be reserved for code needed to configure the engine infrastructure instead of setup, configuration, and override code that would normally go in `config/initializers` in a Hyku application.  There are additional hooks for different stages of the initialization process available within the `Engine` as described by https://edgeguides.rubyonrails.org/engines.html#available-configuration-hooks.

### I18n Locales
Locale files can be overridden or added in `config/locales`.  The locale files in this engine are appended to `I18n.load_path` so they have precedence over Hyku and Hyrax's locales.

#### Customizing locales per tenant
I18n locales can be customized to override default translations for a specific tenant with fallbacks to the original translations.  To do this, create a locale file in `config/locales` that matches the name of an existing locale file but with `-TENANT_NAME` appended to the name.  For example, `en.yml` can be overriden for tenant `demo` with a file called `en-DEMO.yml`.  *Be sure to name the YAML root the same as the tenant (`en-DEMO:` in the example above).*

### Generators
Any generators that this engine provides downstream to Hyku should be defined in `lib/generators/hyku_addons/`.  Generators provided by rails or other gems/engines can be run like normal from this engine's root (e.g. `rails g job UbiquityExporter`).

### Rake Tasks
Rake tasks for use in the application (not internal to this engine) should be defined in `lib/tasks`.  When working on this engine rake tasks from Hyku can be run by prepending the `app` namespace (e.g. `rake app:db:migrate`).

### Enabling Features
Customizations and overrides included in this engine should be put behind a `Flipflop` feature that is disabled by default.  Doing this allows these customizations to be enabled (or disabled) per Hyku instance and even per tenant.

### Overriding Hyku/Hyrax

There are many approaches to overriding and which to use will depend on the context.  For views that need to be overridden copy the file into this engine at the same path as the original.  For classes it may be possible to create a new module containing the overrides and then prepend it into the original class in an initializer.

When behavior that is tested in Hyku changes, copy the relevant test files from the internal test hyku into the engine at the same path as the original.  This will cause rspec to skip the original tests in favor of the engine's copy of them.

## Development

The rails server will be running at http://hyku.docker and tenants will be subdomains like http://tenant1.hyku.docker.

Check out the code then initialize the internal test hyku application:
```
git submodule init
git submodule update --remote
bundle install
bundle exec rails g hyku_addons:install

# If you are using Docker, you will need to do the `hyku_addons:install` within the container
docker-compose exec web bundle exec rails g hyku_addons:install

# If you see an error where by Zookeeper cannot be installed via Bundler, the following should work:
CFLAGS=-Wno-error=format-overflow  gem install zookeeper -v '1.4.11' --source 'https://rubygems.org/'
```

### Dory / Host file

Dory can be used to automatically configure your local development environment so that you can use local subdomains, however you may experience issues. (See https://github.com/samvera/hyku/#dory)

Another solution is to simply edit your `/etc/hosts` file and add in each tenants cname here. For example: 

```
sudo vim /etc/hosts
```
And add the following: 

```
# ... Existing content

# Hyku
127.0.0.1       hyku.docker          # The main account section 
127.0.0.1       repo.hyku.docker
127.0.0.1       pacific.hyku.docker
```

You can now access the repositories by suffixing the URL with `:3000`, for instance: http://hyku.docker:3000

You will need to add each new tenant cname to your host file when a new account is added.  

### Docker

Running a docker development environment is possible by running:
```
docker-compose build
docker-compose up web workers
```

Attaching to the hyku container to run commands can be done by running:
```
docker-compose exec web /bin/bash
```

### Setting up an account and super admin

There are a few options and steps here, so we will outline the easiest possible path to get you up and running.

#### Create a Super Admin

Enter bash inside container

```sh
docker-compose exec web /bin/bash
```

Using the following command you will be asked to enter an email address and password

```sh
bundle exec rails app:hyku_addons:superadmin:create
```

#### Create an account

##### Via app interface

Goto the accounts screen http://hyku.docker/proprietor/accounts?locale=en

##### Via console

Hyku has option to create an account via the command line. You will first need a valid UUID. Goto the console:

```sh
docker-compose exec web bundle exec rails console
```

Copy the string returned from secure random for use as the account UUID

```ruby
# Copy this to your clipboard
SecureRandom.uuid
```

The account create command requires 4 arguments:

+ Account name - lower case and hyphen seperated
+ UUID - copied from above
+ CNAME - full domain of the account tenant without the rails testing port (3000), i.e. test.hyku.docker
+ Admin Email - The email address of the user you created above

```sh
# Example
docker-compose exec web bundle exec rails "app:hyku:account:create[test, aa070467-09d7-4b13-bb5a-7192f900e6c3, test.hyku.docker, your-email@address.com]"
```

### Activate user

Your user will need to be activated as invitations are not sent from local development environments. Enter the rails console:

```sh
docker-compose exec web bundle exec rails console
```

```ruby
# Set the account to the one you have just created. For example:
AccountElevator.switch!(Account.first.cname)

# NOTE: The password is being set again as it doesn't seem to be correct when trying to login
User.first.update(invitation_token: nil, invitation_accepted_at: DateTime.current, password: 'test1234')
```

### Testing

Tests are run automatically on CircleCI with rubocop and codeclimate.  These tests must pass before pull requests can be merged.

To run the tests locally inside docker run:
```
docker-compose exec web /bin/bash
bundle exec rspec `find spec -name *_spec.rb | grep -v internal_test_hyku`
```

To run the tests locally outside of docker do the following with each line in its own shell from the root of the engine:
```
cd spec/internal_test_hyku && solr_wrapper -v --config config/solr_wrapper_test.yml
fcrepo_wrapper -v --config spec/internal_test_hyku/config/fcrepo_wrapper_test.yml
DISABLE_REDIS_CLUSTER=true bundle exec sidekiq -r spec/internal_test_hyku/
SETTINGS__MULTITENANCY__ADMIN_HOST=localhost DISABLE_REDIS_CLUSTER=true RAILS_ENV=test bundle exec rails server -b 0.0.0.0
bundle exec rspec `find spec -name *_spec.rb | grep -v internal_test_hyku`
```
You shouldn't need to run anything from inside `spec/internal_test_hyku` unless explicitly told to do so.

Note that at this time the application must be run in test mode due to a bug in loading the development environment.

### Debugging

Byebug is installed and can be used in tests and the running rails server. You will need to start your web containers in 'detached' mode and then attach to the container to interact with byebug:

```
docker-compose up -d web
docker attach hyku_addons_web_1
```

### Updating the internal test app

Hyku Addons uses a custom version of Hyrax that we call `hyku_base` which is added as a Git submodule. It is a fork of Hyku 2 just before Hyku 3 without the user elevation plus newer commits that have been cherry-picked. 
In order to apply new commits that have been made into Hyrax/Hyku, we need to bring them first into `hyku_base` as [described here](https://github.com/ubiquitypress/hyku_base#updating-the-app) and then update the git submodule.

Make sure you have a clean internal test app before doing the `git add`, otherwise Git will not add the submodule as it will consider it dirty.

The process is:
1. Update the submodule with `git submodule update --remote`
2. Run `bundle exec rails g hyku_addons:install`
3. Run the tests
4. When the tests pass, run `git diff` to see the new revision number of the submodule, which will be prefixed by "-dirty".
This happens because of additional files generated in step 2
5. Some of the changes that `hyku_addons:install` makes are modifications of existing files instead and others are just new files.
The modified files needs to be restored to their original state using `git restore`. The new ones need to be deleted. 
6. Running `git diff` again should show the new submodule revision number without appending "-dirty" to the end. 
7.`git add spec/internal_test_hyku`
8.`git commit`

