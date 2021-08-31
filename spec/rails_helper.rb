# frozen_string_literal: true
# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
require File.expand_path('internal_test_hyku/spec/rails_helper.rb', __dir__)

ENV['RAILS_ENV'] ||= 'test'
# require File.expand_path('../config/environment', __dir__)
require File.expand_path('internal_test_hyku/config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'factory_bot_rails'
FactoryBot.definition_file_paths = [File.expand_path("spec/factories", HykuAddons::Engine.root)]
FactoryBot.find_definitions

# For testing generators
require 'ammeter/init'

# Optional execution of specs for examples that fail randomly on CI
require File.expand_path('support/optional_example', __dir__)

if ENV['CI']
  # Capybara config copied over from Hyrax
  Capybara.register_driver :selenium_chrome_headless_sandboxless do |app|
    browser_options = ::Selenium::WebDriver::Chrome::Options.new
    browser_options.args << '--headless'
    browser_options.args << '--disable-gpu'
    browser_options.args << '--no-sandbox'
    # browser_options.args << '--disable-dev-shm-usage'
    # browser_options.args << '--disable-extensions'
    # client = Selenium::WebDriver::Remote::Http::Default.new
    # client.timeout = 90 # instead of the default 60
    # Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options, http_client: client)
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
  end

  Capybara.default_driver = :rack_test # This is a faster driver
  Capybara.javascript_driver = :selenium_chrome_headless_sandboxless # This is slower
  Capybara.default_max_wait_time = 10 # We may have a slow application, let's give it some time.

  # FIXME: Pin to older version of chromedriver to avoid issue with clicking non-visible elements
  Webdrivers::Chromedriver.required_version = '72.0.3626.69'
end

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Require supporting ruby files from spec/support/ and subdirectories.  Note: engine, not Rails.root context.
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }

require 'shoulda-matchers'
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # They enable url_helpers not to throw error in Rspec system spec and request spec.
  # config.include Rails.application.routes.url_helpers
  config.include HykuAddons::Engine.routes.url_helpers

  # Use this example metadata when you want to perform jobs inline during testing.
  #
  #   describe '#my_method`, :perform_enqueued do
  #     ...
  #   end
  #
  # If you pass an `Array` of job classes, they will be treated as the filter list.
  #
  #   describe '#my_method`, perform_enqueued: [MyJobClass] do
  #     ...
  #   end
  #
  # Limit to specific job classes with:
  #
  #   ActiveJob::Base.queue_adapter.filter = [JobClass]
  #

  config.around(:example, :perform_enqueued) do |example|
    ActiveJob::Base.queue_adapter.filter =
      example.metadata[:perform_enqueued].try(:to_a)
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs    = true
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true

    example.run

    ActiveJob::Base.queue_adapter.filter = nil
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs    = false
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = false
  end

  # Add support for conditional execution of specs
  config.include OptionalExample

  ## Override spec/internal_test_hyku/spec/support/multitenancy_metadata.rb by setting ENV
  # because the mocking of Settings.multitenancy gets overwritten by the Settings reloading
  # that happens in Account#switch!
  #
  # The before and after blocks must run instantaneously, because Capybara
  # might not actually be used in all examples where it's included.
  config.after do
    example = RSpec.current_example
    ENV.delete('SETTINGS__MULTITENANCY__ENABLED') if example.metadata[:multitenant] || example.metadata[:singletenant]
  end

  # There are 3 optional flags available to a test block.  Only ONE will be active
  # at any given time.  They are (with areas of likely use):
  #   :multitenant  - general case default, only needs to be explicit for types described below
  #   :singletenant - For tests explicitly written for singletenancy, in particular routing
  #   :faketenant   - Ignoring multitenancy, but pretending *some* tenant is always active
  #
  # Spec types:
  #   :feature - Because multitenancy affects routing, all :feature tests default to :singletenant.
  #              Similarly, :feature tests cannot use :faketenant (would fail anyway).
  #   :controller - default to :faketenant, since most resource controllers can be tested
  #                 without routing as long as they get some account.

  config.before do
    example = RSpec.current_example
    ENV['SETTINGS__MULTITENANCY__ENABLED'] = 'true' if example.metadata[:multitenant] || example.metadata[:faketenant] || example.metadata[:type] == :controller
    ENV['SETTINGS__MULTITENANCY__ENABLED'] = 'false' if example.metadata[:singletenant] || example.metadata[:type] == :feature

    # Ensure that Hirmeos is always enabled or all the feature tests will fail
    allow(Hyrax::Hirmeos).to receive(:configured?).and_return(true)
  end
  ## End override
end
