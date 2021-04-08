# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'hyku-api', git: 'https://github.com/ubiquitypress/hyku-api', branch: 'main'
gem 'hyrax-doi', git: 'https://github.com/samvera-labs/hyrax-doi', branch: 'main'
gem 'json-diff'

# Declare your gem's dependencies in hyku_addons.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]
# gem 'mini_racer'

eval_gemfile File.expand_path('spec/internal_test_hyku/Gemfile', File.dirname(__FILE__))
