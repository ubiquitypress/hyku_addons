# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "hyku_addons/version"

Gem::Specification.new do |spec|
  spec.name = "hyku_addons"
  spec.version     = HykuAddons::VERSION
  spec.authors     = ["Chris Colvard"]
  spec.email       = ["chris.colvard@gmail.com"]
  spec.homepage    = ""
  spec.summary     = "Ubiquity Press Addons to Hyku"
  spec.description = "Addons to Hyku that are specific to Ubiquity Press."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "blacklight_oai_provider", "~> 6.1"
  spec.add_dependency "config", ">= 3.0"

  # TODO: make the gcloud dependency optional?
  spec.add_dependency "google-cloud-storage", "~> 1.31"
  spec.add_dependency "google-cloud-pubsub", "~> 2.6.1"
  spec.add_dependency "workos", "~> 2.10"

  spec.add_dependency "hyrax", "~> 2.8"
  spec.add_dependency "rdf", "3.2.4"
  spec.add_dependency "rdf-n3", "3.1.1"
  spec.add_dependency "hyrax-doi"
  spec.add_dependency "bolognese"

  # Pins to help bundler resolve
  spec.add_dependency "postrank-uri", ">= 1.0.24"
  spec.add_dependency "public_suffix", "~> 2.0.2"
  spec.add_dependency "lograge"
  spec.add_dependency "devise-i18n", "~> 1.10.0"
  spec.add_dependency "devise-guests", "<= 0.7.0"
  # Added for shared search nested attributes
  spec.add_dependency "cocoon", "~> 1.2", ">= 1.2.9"

  spec.add_development_dependency "ammeter"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "bixby"
  spec.add_development_dependency "bootsnap"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "shoulda-matchers"
  spec.add_development_dependency "webdrivers", "~> 4.0"
  spec.add_development_dependency "test-prof"
  spec.add_development_dependency "stackprof"
  spec.add_development_dependency "ruby-prof"
  spec.add_development_dependency "rubocop", "~> 1"
end
