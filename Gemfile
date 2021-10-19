# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'hyku-api', git: 'https://github.com/ubiquitypress/hyku-api', branch: 'main'
gem 'hyrax-doi', git: 'https://github.com/samvera-labs/hyrax-doi', branch: 'main'
gem 'hyrax-hirmeos', git: 'https://github.com/ubiquitypress/hyrax-hirmeos', branch: 'main'
gem 'hyrax-orcid', git: 'https://github.com/ubiquitypress/hyrax-orcid', branch: 'main'

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

# Try and update Rubocop/bixby and related Gems locks in 2018
gem 'rubocop', require: false
gem 'rubocop-performance', require: false
gem 'rubocop-rails', require: false
gem 'rubocop-rspec', require: false

file_name = File.expand_path('spec/internal_test_hyku/Gemfile', File.dirname(__FILE__))
text = File.read(file_name)
new_contents = text.gsub(/gem 'rubocop', '~> 0.50', '<= 0.52.1'/, "")
                   .gsub(/gem 'rubocop-rspec', '~> 1.22', '<= 1.22.2'/, "")
                   .gsub(/gem 'parser', '~> 2.5.3'/, "")

File.open(file_name, "w") { |file| file.puts new_contents }

# Eval the ammended Gemfile from Hyku Base.
eval_gemfile file_name
