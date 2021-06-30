# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'hyku-api', git: 'https://github.com/ubiquitypress/hyku-api', ref: 'da983b76de8a25967bccaa21874e32445c1bc85c'
gem 'hyrax-doi', git: 'https://github.com/samvera-labs/hyrax-doi', branch: 'main'
gem 'hyrax-hirmeos', git: 'https://github.com/ubiquitypress/hyrax-hirmeos', branch: 'main'

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
