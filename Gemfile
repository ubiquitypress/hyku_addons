# frozen_string_literal: true
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in hyku_addons.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# Had to specify these explicitly in the internal_test_hyku's Gemfile and pin stuff for bundler to resolve
# I'm not sure if here is sufficient or if they actually have to be in Hyku's Gemfile
gem 'hyrax-doi'
gem 'maremma', '< 4.8'
gem 'postrank-uri', '>= 1.0.24'

# To use a debugger
# gem 'byebug', group: [:development, :test]
# gem 'mini_racer'

eval_gemfile File.expand_path('spec/internal_test_hyku/Gemfile', File.dirname(__FILE__))
