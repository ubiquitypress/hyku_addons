# HykuAddons
Code: [![CircleCI](https://circleci.com/gh/ubiquitypress/hyku_addons.svg?style=svg)](https://circleci.com/gh/ubiquitypress/hyku_addons)
[![Code Climate](https://codeclimate.com/github/ubiquitypress/hyku_addons/badges/gpa.svg)](https://codeclimate.com/github/ubiquitypress/hyku_addons)

Docs: [![Contribution Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./CONTRIBUTING.md)
[![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)

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

### Routes

https://github.com/ubiquitypress/hyku_addons/wiki/HykuAddons:-Routes

### Database Migrations

https://github.com/ubiquitypress/hyku_addons/wiki/HykuAddons:-Database-migrations

### Initializers

Initializers that should be run within Hyku can be added to `config/initializers` like in a Rails application.  They can also be added as `initializer` blocks within the `Engine` class, but that should be reserved for code needed to configure the engine infrastructure instead of setup, configuration, and override code that would normally go in `config/initializers` in a Hyku application. There are additional hooks for different stages of the initialization process available within the `Engine` as described by https://edgeguides.rubyonrails.org/engines.html#available-configuration-hooks.

### I18n Locales

How to add locales for specific tenants, changing the contents of form dropdown menus and form field labels.

https://github.com/ubiquitypress/hyku_addons/wiki/Hyku:Addons-Tenant-Locales

### Generators

Any generators that this engine provides downstream to Hyku should be defined in `lib/generators/hyku_addons/`.  Generators provided by rails or other gems/engines can be run like normal from this engine's root (e.g. `rails g job UbiquityExporter`).

### Rake Tasks

Rake tasks for use in the application (not internal to this engine) should be defined in `lib/tasks`.  When working on this engine rake tasks from Hyku can be run by prepending the `app` namespace (e.g. `rake app:db:migrate`).

### Enabling Features

Customizations and overrides included in this engine should be put behind a `Flipflop` feature that is disabled by default.  Doing this allows these customizations to be enabled (or disabled) per Hyku instance and even per tenant.

### Overriding Hyku/Hyrax

There are many approaches to overriding and which to use will depend on the context.  For views that need to be overridden copy the file into this engine at the same path as the original.  For classes it may be possible to create a new module containing the overrides and then prepend it into the original class in an initializer.

When behavior that is tested in Hyku changes, copy the relevant test files from the internal test hyku into the engine at the same path as the original.  This will cause rspec to skip the original tests in favor of the engine's copy of them.

### Work Schema and creating new work types

https://github.com/ubiquitypress/hyku_addons/wiki/HykuAddons:-Creating-new-work-types

### Local Development

https://github.com/ubiquitypress/hyku_addons/wiki/HykuAddons:-Local-Development

#### Create an Tenant (Account) and setting up Hyku Addons

https://github.com/ubiquitypress/hyku_addons/wiki/HykuAddons:-Setup-Guide

### Development using a local Gem

https://github.com/ubiquitypress/hyku_addons/wiki/HykuAddons:-Development-using-a-local-Gem

### Testing

https://github.com/ubiquitypress/hyku_addons/wiki/HykuAddons:-Testing

### Updating the internal test app

https://github.com/ubiquitypress/hyku_addons/wiki/HykuAddons:-Updating-Hyku-Base

### Dependency Management

https://github.com/ubiquitypress/hyku_addons/wiki/Hyku:-Dependency-Management
