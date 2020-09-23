# frozen_string_literal: true
module HykuAddons
  class InstallGenerator < Rails::Generators::Base
    desc <<-EOS
      This generator makes the following changes to Hyku:
        1. Installs and configures hyrax-doi
    EOS

    source_root File.expand_path('templates', __dir__)

    def install_hyrax_doi
      generate 'hyrax:doi:install --datacite'
      # Configure default_url_options
      # Rails.application.routes.default_url_options[:host] = 'lvh.me:3000' ?

      # generate 'hyrax:doi:add_to_work_type GenericWork --datacite'
    end
  end
end
