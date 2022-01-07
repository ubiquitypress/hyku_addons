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

### Application code

All code that would normally go under `app` in Hyku (controllers, mailers, helpers, jobs, models, etc.) still does in this engine.

### Views

Views provided by this engine are prepended to the view path so they take precedence over Hyku and Hyrax views.  To override a view from Hyku or Hyrax copy it to the same relative path within this engine then modify it.

### Routes

Routes added by this engine are declared in `config/routes.rb` just like a normal Rails application.  Normally an engine's routes are mounted in an application's `routes.rb` but this engine mounts them automatically during initialization to avoid the need of modifying any file in Hyku other than `Gemfile`.

If you need to reference a Hyku route using a route helper then you can access it through `main_app`.  If it is a Hyrax route then use `hyrax`.  For example:

```ruby
  redirect_to main_app.new_user_registration_url
  redirect_to hyrax.dashboard_path
```

### Database Migrations

#### Production - Ubiquity Press specific

Database migraions in production are not currently automatically run when the application is deployed - although this is a feature that should be added.

Because of the current way that migrations are handled it is necessary to deploy your changes, then log into your production environment, manually run `db:migrate`.

Log into your production environment, which for Google Cloud would be:

```bash
kubectl get pods | grep hyku

kubectl exec -it hyku-pod-name -- /bin/bash

bundle exec rails db:migrate
```

#### Development

Migrations for database changes introduced by this engine are defined in `db/migrate` like any Rails application.  These get copied into Hyku during installation when the following in run:

```bash
bundle exec rails app:hyku_addons:install:migrations
```

These files are suffixed by the engine name for easy identification (e.g. `20200103172822_add_contact_email_to_sites.hyku_additions.rb`).  This command is safe to rerun and will only copy over missing migrations.  See https://edgeguides.rubyonrails.org/engines.html#engine-setup for more details.

To perform the migration you will need to scope the command as follows:

```bash
bundle exec rails db:migrate SCOPE=hyku_addons
```

Don't forget to run the test migations at the same time:

```bash
RAILS_ENV=test bundle exec rails db:migrate
```

##### Adding Migrations

When writing migration they must use the `up/down` syntax and check if a table has already been created. This is because migrations might be installed more than one in development, or when tenants are added in production, their migrations need to be run after the initial migration may have been executed.  Checking at a per line level in the migration also assists when re-running a failed migration manually.

```ruby
# Example of how to check if a table currently exists
class CreateAccountCrossSearches < ActiveRecord::Migration[5.2]
  def self.up
    return if table_exists?(:account_cross_searches)

    create_table :account_cross_searches do |t|
      t.references :search_account, foreign_key: { to_table: :accounts }
      t.references :full_account, foreign_key: { to_table: :accounts }

      t.timestamps
    end
  end

  def self.down
    drop_table(:account_cross_searches)
  end
end
```

When adding columns you must follow the same pattern.  Note that when adding indicies or foreign keys they must be added after column creation, and removed before the columns are removed:

```ruby
class AddDisplayProfileToUsers < ActiveRecord::Migration[5.2]
  def self.up
    add_column      :users, :display_name, :string      unless column_exists?(:users, :display_name)
    add_index       :users, :display_name, unique: true unless index_exists?(:users, :display_name, unique: true)
    add_column      :users, :jobtitle_id, :integer      unless column_exists?(:users, :jobtitle_id)
    add_foreign_key :users, :jobtitles                  unless foreign_key_exists?(:users, :jobtitles)
  end

  def self.down
    remove_foreign_key :users, :jobtitles    if foreign_key_exists?(:users, :jobtitles)
    remove_index       :users, :display_name if index_exists?(:users, :display_name, unique: true)
    remove_column      :users, :display_name if column_exists?(:users, :display_name)
    remove_column      :users, :jobtitle_id  if column_exists?(:users, :jobtitle_id)
  end
end
```
Also note that when checking the existence of an index or foreign key you must correctly specify options such as unique for ActiveRecord to return a match.

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

### Work Schema

Hyku Addons uses a port of the Hyrax 3.0 Schema YAML to define work types, whilst trying to maintain backwards compatability for older works already defined.

#### Defining the Schema

##### For new works

Your Schema should be defined in `config/metadata` as a `.yaml` file that matches the underscored name of your work type. So the UbiquityTemplateWork has a file called `ubiquity_template_work.yaml`.

##### For existing works

If you are migrating an existing work, there is a rake task you can run which will attampt to generate the schema from the exising work properties and uses a set of default configurations for JSON and other complicated fields:

```bash
docker-compose exec web bundle exec rails app:hyku_addons:model:generate_schema[ubiquity_template_work]
```

Once the task has run, make sure that the permissions on the generated file allow you to make changes (`chmod 777 config/metadata/ubiqiuty_template_work.yaml` or something similar), then you can compare the generated fields to the required fields within the dashboard.

##### Schema Examples

Below are a set of example fields that illustrate how to define different types of fields:

```yaml
---
# Starts with an attributes hash
attributes:
  # Multiple text field example
  alt_title:
    type: string
    predicate: http://purl.org/dc/terms/alternative
    multiple: true
    index_keys:
      - alt_title_tesim
    form:
      required: false
      primary: false
      multiple: true
      type: text

  # Custom input type example
  title:
    type: string
    predicate: http://purl.org/dc/terms/title
    multiple: true
    index_keys:
      - title_tesim
      - title_sim
    # The form hash defines how the field will be presented in the form
    form:
      # Browser required, but not backend validated
      required: true
      # Should the field be above the fold
      primary: true
      multiple: true
      type: text
      # If you have a field that needs custom behavior, you can define a SimpleForm Input class and add it here,
      # in this case, `title` is a multiple field (for hyrax compatability) but only shows a single text input.
      input: single_multi_value

  # Textarea field example
  abstract:
    type: text
    predicate: http://purl.org/dc/terms/abstract
    multiple: true
    index_keys:
      - abstract_tesim
    form:
      required: false
      primary: false
      multiple: true
      type: textarea

  # Select field example
  subject:
    predicate: http://purl.org/dc/elements/1.1/subject
    multiple: true
    index_keys:
      - subject_tesim
    form:
      required: false
      primary: false
      multiple: true
      # For select fields an authority class is required, which will be constantized in the form
      type: select
      authority: HykuAddons::SubjectService

  # JSON field example
  related_identifier:
    type: string
    predicate: http://id.loc.gov/ontologies/bibframe/identifiedBy
    multiple: true
    index_keys:
      - related_identifier_tesim
    form:
      required: false
      primary: false
      multiple: true
      type: text
    subfields:
      related_identifier:
        type: string
        form:
          multiple: false
          required: false
          type: text
      related_identifier_type:
        type: string
        form:
          required: false
          multiple: false
          type: select
          authority: HykuAddons::RelatedIdentifierTypeService
          include_blank: true
      relation_type:
        type: string
        form:
          required: false
          multiple: false
          type: select
          authority: HykuAddons::RelationTypeService
          include_blank: true

  # Custom field attributes example
  creator_institutional_relationship:
    # ...
    form:
      # ...
      # The attributes array can contain any of the field attributes you want inserted into the field markup
      attributes:
        multiple: multiple
        data:
          foo: bar
```

#### Adding the required concerns

Once the schema has been created you can add the Schema Concerns to your model, form, presenter and indexer.

The work modal:

```ruby
class UbiquityTemplateWork < ActiveFedora::Base
  # ...
  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:ubiquity_template_work)
  self.indexer = UbiquityTemplateWorkIndexer
  # ...
```

The Work Form:

```ruby
module Hyrax
  class UbiquityTemplateWorkForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ubiquity_template_work)
    # ...
```

The Indexer:

```ruby
class UbiquityTemplateWorkIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ubiquity_template_work)
  # ...
```

The presenter:

```ruby
module Hyrax
  class UbiquityTemplateWorkPresenter < Hyrax::WorkShowPresenter
    # ...
    include ::HykuAddons::Schema::Presenter(:ubiquity_template_work)
    include ::HykuAddons::PresenterDelegatable
    # ...
  end
end
```

#### Checking its worked

If you restart your Rails server or Docker containers and create the new work within the Hyku Addons dashabord you will be able to check the generated page source within the browser debugger. If everything has worked properly the field divs should be preceeded by an HTML comment indicating which view partial was included to generate the field:

```html
<!-- _resource_type -->
<!-- schema - _default - resource_type -->
<div class="form-group single_multi_value required uva_work_resource_type">
//...
```

This pattern is used as much as possible to indicate which partials are being used, first `_resource_type` is found, which delegate to the `_default`. `schema` indicates that the field is passing through the schema rendering within the partials. Eventually this can all be removed along with all of the delegating partials, leaving just `_default`, but for now we need to maintain backwards compatability for older work types.

#### Specs

There is a (pretty much) complete test for the Ubiquity Template Work (`spec/features/ubiquity_template_work_form_spec.rb`), which confirms that the actual form fields can be completed, that the form is submitted and then that the data is saved to the Fedora record. For new work types you should be able to duplicate from that spec and remove the fields that are not relevant, or using the form field helps, add new fields as required.

The only way to know if a work type is working for the user is if there are specs.

Whereever possible the Authorities or dynamic data should be used, this is to ensure that the spec works for more than the single example provided.

```ruby
# Get an array of two random elements from the authority
let(:license_options) { HykuAddons::LicenseService.new.active_elements.sample(2) }

# Use the labels to fillin the form field using the `fill_in_` helpers.
fill_in_multiple_selects(:license, license_options.map { |h| h["label"] })

# Confirm that the IDs were saved to the work record
expect(work.license).to eq(license_options.map { |h| h["id"] })
```

#### The Note fields

One thing to note is that the `note` field should not be included in the works schema YAML. This is because it resides outside of the form fields content in its own tab and because of this should be added to a work/form by including the concerns:

```ruby
# Model class
class UvaWork < ActiveFedora::Base
  include Hyrax::WorkBehavior
  # ...
  include HykuAddons::NoteBehavior

# Form class
module Hyrax
  class UvaWorkForm < Hyrax::Forms::WorkForm
    # ...
    include HykuAddons::NoteFormBehavior
```

## Development

The rails server will be running at http://hyku.docker and tenants will be subdomains like http://tenant1.hyku.docker.

Check out the code then initialize the internal test hyku application:

```bash
git submodule init
git submodule update --remote
bundle install
bundle exec rails g hyku_addons:install

# Start the containers
docker-compose up --build

# If you are using Docker, you will need to do the `hyku_addons:install` within the container
docker-compose exec web bundle exec rails g hyku_addons:install

# If you see an error where by Zookeeper cannot be installed via Bundler, the following should work:
CFLAGS=-Wno-error=format-overflow gem install zookeeper -v '1.4.11' --source 'https://rubygems.org/'

# If you get the following Postgres error "Could not create Makefile due to some reason, probably lack of necessary libraries and/or headers", you may need to install Postgres, which on Ubuntu/Debian linux can be done with the following:

sudo apt install postgresql-server-dev-all

# You can then install Postgress natively:

gem install pg -v '1.2.3' --source 'https://rubygems.org/'

```

### Dory / Host file

Dory can be used to automatically configure your local development environment so that you can use local subdomains, however you may experience issues. (See https://github.com/samvera/hyku/#dory)

Another solution is to simply edit your `/etc/hosts` file and add in each tenants cname here. For example:

```
sudo vim /etc/hosts
```

And add the following:

```bash
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
docker-compose up --build
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

```bash
docker-compose exec web bin/rspec
```

In order to make local development more practical, slow tests are not run by default. All these tests slow tests are run on CI by default.
Use the following command to run them locally:

```bash
docker-compose exec web bin/rspec --tag @slow
```

To run the tests locally outside of docker do the following with each line in its own shell from the root of the engine:

```bash
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

```bash
docker-compose up -d
docker attach hyku_addons_web_1
```

### Using a local Gem

If you wish to use a local version of a gem, from your host machine, then you will need to make changes in 3 locations. I will use the Hyrax-Oricid Gem as an example below:

In the `Dockerfile` add the following to create a directory where your local Gem will be copied to:

```dockerfile
RUN mkdir /home/app/hyrax-orcid
```

In the `docker-compose.yml`, inside of the `&app` configuration block, which is the path to the local gem and the path to the location added above:

```yml
app: &app
  #...
  volumes:
  #...
  - /home/paul/Ubiquity/hyrax-orcid:/home/app/hyrax-orcid
```

In your HykuAddons `Gemfile`:

```ruby
gem 'hyrax-orcid', path: "/home/app/hyrax-orcid"
```

Now you can build the app again with `docker-compose build` and then `up` and you should be able to make Gem changes and see them on the next request.

### Updating the internal test app

Hyku Addons uses a custom version of Hyku that we call `hyku_base` which is added as a Git submodule. It is a fork of Hyku 2, just before Hyku 3 without the user elevation plus newer commits that have been cherry-picked.
In order to apply new commits that have been made into Hyrax/Hyku, we need to bring them first into `hyku_base` as [described here](https://github.com/ubiquitypress/hyku_base#updating-the-app) and then update the git submodule.

Make sure you have a clean internal test app before doing the `git add`, otherwise Git will not add the submodule as it will consider it dirty.

The process is:

1. Update the submodule with `git submodule update --remote`
2. Run `bundle exec rails g hyku_addons:install`
3. [Run the tests](https://github.com/ubiquitypress/hyku_addons#testing)
4. When the tests pass, run git diff to see the new revision number of the submodule, which will be prefixed by "-dirty".
   This happens because of additional files generated in step 2
5. Some of the changes that `hyku_addons:install` makes are modifications of existing files instead and others are just new files.
   The modified files needs to be restored to their original state using `git restore`, the new ones should be deleted.
6. Running `git diff` again should show the new submodule revision number without appending "-dirty" to the end.
7. You can now add your changes: `git add spec/internal_test_hyku`
8. And commit them: `git commit`

### Dependency Management

#### Gemfiles

HykuAddons employs a number of Gems to bring in dependencies:

+ hyku_addon/Gemfile
+ hyku_addon/hyku_addon.gemspec
+ hyku_addon/spec/internal_test_hyku/Gemfile
+ advancinghyku-utils/gemfile.plugins

These service difference purposes depending on context.

##### hyku_addons/Gemfile

The Gemfile for the project is uses for local development and actions performed witin the application directory, `rails g`, `rake` etc.

##### hyku_addons/hyku_addon.gemspec

Used in the context of the gem and for bundler build dependencies when installing as a gem. Any application using HA, now uses these dependencies as well.

##### hyku_addon/spec/internal_test_hyku/Gemfile

Included into the hyku_addons/Gemfile when the application is started, brings all upstream dependencies.

##### advancinghyku-utils/gemfile.plugins

Uses internally for production builds within the deployment pipeline. Takes precedence over the other files mentioned, so if you pin a version in this file, you can prevent the application using an updated version of the gem.

An example is the hyku-api gem that was pinned to a version before a breaking change, which was in active development, was pushed.

```ruby
gem 'hyku-api', git: 'https://github.com/ubiquitypress/hyku-api', ref: 'd7cd47d396a6f3695188001bb3447ad97e766124'
```

Using tagged releases would obviously solve the need for this, but at the time this was not possible.

To enable updates to a pinned gem, like hyku-api shown above, simply reset it to track `main` and then `bundle update gem-name` from within the hyku_addons application.

#### Production builds - advancinghyku-utils

In order to build the hyku_addons application, the hyku_base (currently a fork of hyku 2.x branch) is checked out and the gemfile.plugins file is copied into the Gemfile. Without this extra step, production environments would not have access to rake/rails generators and tasks - which is apparently a Rails quirk that no one properly understands. This also means that gems can be pinned to versions, which isn't possible within a gemspec file, which enforces only rubygems references are used.

The gemfile.lock from hyku_addons is copied into the hyku_base project to override their default Gemfile.lock - this solved an issue where by bundler wasn't able to compute builds correctly and wasn't pulling latest versions.

### Development Environments

If you are a developer looking to build upon Hyku Addons, then you are probably using some kind of development tool, Vim, VS Code etc. Because of the dependency on an older version of Rubocop, you will need to use an older version of the Ruby Language Server Solargraph:

```bash
gem install solargraph -v 0.39.17
```
