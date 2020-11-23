# frozen_string_literal: true
module HykuAddons
  class InstallGenerator < Rails::Generators::Base
    desc <<-EOS
      This generator makes the following changes to Hyku:
        1. Installs and configures hyrax-doi
    EOS

    source_root File.expand_path('templates', __dir__)

    def inject_dependencies
      gem 'hyrax-doi'
      gem 'allinson_flex', git: 'https://github.com/samvera-labs/allinson_flex.git'
      # Manually add this to avoid loading issue where Rails/AllinsonFlex tries to load Webpacker
      # before the allinson_flex:install generator has a chance to install the webpacker gem 
      gem 'webpacker'

      Bundler.with_clean_env do
        run "bundle install"
      end
    end

    def install_allinson_flex
      generate 'allinson_flex:install'
      rake 'webpacker:install'
      rake 'webpacker:install:react'
      # Here below may fail due to a incorrectly formatted webpacker.yml
      generate 'react:install'
      insert_into_file 'app/assets/stylesheets/application.css', after: /^ *= require hyrax/ do
        " *= require allinson_flex/application\n"
      end
      insert_into_file 'app/assets/javascripts/application.js', after: /^\/\/= require hyrax/ do
        "//= require allinson_flex/application\n"
      end
    end

    def install_hyrax_doi
      generate 'hyrax:doi:install --datacite'
    end
  end
end
