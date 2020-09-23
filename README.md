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
Migrations for database changes introduced by this engine are defined in `db/migrate` like any Rails application.  These get copied into Hyku during installation when `rake hyku_additions:install:migrations` is run.  These files are suffixed by the engine name for easy identification (e.g. `20200103172822_add_contact_email_to_sites.hyku_additions.rb`).  This command is safe to rerun and will only copy over missing migrations.  See https://edgeguides.rubyonrails.org/engines.html#engine-setup for more details.

### Initializers
Initializers that should be run within Hyku can be added to `config/initializers` like in a Rails application.  They can also be added as `initializer` blocks within the `Engine` class, but that should be reserved for code needed to configure the engine infrastructure instead of setup, configuration, and override code that would normally go in `config/initializers` in a Hyku application.  There are additional hooks for different stages of the initialization process available within the `Engine` as described by https://edgeguides.rubyonrails.org/engines.html#available-configuration-hooks.

### I18n Locales
Locale files can be overridden or added in `config/locales`.  The locale files in this engine are appended to `I18n.load_path` so they have precedence over Hyku and Hyrax's locales.

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
Then granting superadmin powers to a new user:
```
bundle exec rake app:hyku:superadmin:grant[username]
```
The rails server will be running at http://lvh.me:3000 and tenants will be subdomains like http://tenant1.lvh.me:3000.

### Testing

Tests are run automatically on CircleCI with rubocop and codeclimate.  These tests must pass before pull requests can be merged.

To run the tests locally outside of docker do the following with each line in its own shell from the root of the engine:
```
cd spec/internal_test_hyku && solr_wrapper -v --config config/solr_wrapper_test.yml
fcrepo_wrapper -v --config spec/internal_test_hyku/config/fcrepo_wrapper_test.yml
DISABLE_REDIS_CLUSTER=true bundle exec sidekiq -r spec/internal_test_hyku/
SETTINGS__MULTITENANCY__ADMIN_HOST=lvh.me DISABLE_REDIS_CLUSTER=true RAILS_ENV=test bundle exec rails server -b 0.0.0.0
bundle exec rspec
```
You shouldn't need to run anything from inside `spec/internal_test_hyku` unless explicitly told to do so.

Note that at this time the application must be run in test mode due to a bug in loading the development environment.
