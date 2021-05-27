# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "hyku_addons/version"

# Describe your gem and declare its dependencies:
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

  spec.add_dependency "rails", "~> 5.2.4", ">= 5.2.4.3"

  spec.add_dependency 'blacklight_oai_provider', '~> 6.1'
  spec.add_dependency 'config', '>= 3.0'
  # TODO: make the gcloud dependency optional?
  spec.add_dependency 'google-cloud-storage', '~> 1.31'
  spec.add_dependency 'google-cloud-pubsub', '~> 2.6.1'
  spec.add_dependency 'hyrax', '~> 2.8'
  spec.add_dependency 'hyrax-doi'
  # Pins to help bundler resolve
  spec.add_dependency 'maremma', '< 4.8'
  spec.add_dependency 'postrank-uri', '>= 1.0.24'
  spec.add_dependency 'public_suffix', '~> 2.0.2'
  spec.add_dependency 'bolognese', '~> 1.9.7'

  spec.add_development_dependency 'ammeter'
  spec.add_development_dependency "bixby"
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency "pg"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'shoulda-matchers'
  spec.add_development_dependency 'webdrivers', '~> 4.0'
end
