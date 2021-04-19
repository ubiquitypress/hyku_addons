# frozen_string_literal: true
module HykuAddons
  class InstallGenerator < Rails::Generators::Base
    desc <<-EOS
      This generator makes the following changes to Hyku:
        1. Installs hyrax-doi
        2. Installs hyrax-hirmeos
        3. Injects work type overrides
        4. Copies controlled vocabularies
        5. Injects javascript
        6. Injects CSS
        7. Injects helpers
        8. Installs workflows
    EOS

    source_root File.expand_path('templates', __dir__)

    def install_hyrax_doi
      generate 'hyrax:doi:install --datacite'
    end

    def install_hyrax_hirmeos
      generate 'hyrax:hirmeos:install'
    end

    def inject_overrides_into_curation_concerns
      insert_into_file(Rails.root.join('app', 'models', 'generic_work.rb'), before: /^  include ::Hyrax::BasicMetadata/) do
        "\n  # HykuAddons initializer will include more modules and then close the work with this include\n  #"
      end
      insert_into_file(Rails.root.join('app', 'models', 'image.rb'), before: /^  include ::Hyrax::BasicMetadata/) do
        "\n  # HykuAddons initializer will include more modules and then close the work with this include\n  #"
      end

      # Replace hyku override to avoid #doi and #isbn methods
      gsub_file(Rails.root.join('app', 'presenters', 'hyrax', 'generic_work_presenter.rb'), '< Hyku::WorkShowPresenter', '< Hyrax::WorkShowPresenter')
      gsub_file(Rails.root.join('app', 'presenters', 'hyrax', 'image_presenter.rb'), '< Hyku::WorkShowPresenter', '< Hyrax::WorkShowPresenter')
      # TODO: contribute this change upstream
      gsub_file(Rails.root.join('app', 'controllers', 'hyrax', 'images_controller.rb'), 'Hyku::WorkShowPresenter', 'Hyrax::ImagePresenter')
    end

    def copy_controlled_vocabularies
      directory HykuAddons::Engine.root.join("config", "authorities"), Rails.root.join("config", "authorities"), force: true
    end

    def inject_javascript
      insert_into_file(Rails.root.join('app', 'assets', 'javascripts', 'application.js'), after: /require hyrax$/) do
        "\n//= require hyku_addons"
      end
    end

    def inject_stylesheet
      insert_into_file(Rails.root.join('app', 'assets', 'stylesheets', 'application.css'), after: /require hyrax$/) do
        "\n *= require hyku_addons/application"
      end
    end

    def inject_into_helper
      insert_into_file(Rails.root.join('app', 'helpers', 'hyrax_helper.rb'), after: 'include Hyrax::DOI::HelperBehavior') do
        "\n" \
        "  # Helpers provided by hyku_addons plugin.\n" \
        "  include HykuAddons::HelperBehavior"
      end
    end

    # These workflows will be loaded on the creation of new tenants
    # To load these in existing tenants run:
    #  `rake tenantize:task[hyrax:workflow:load]`
    def install_workflows
      template('hyku_addons_mediated_deposit_workflow.json.erb', "config/workflows/hyku_addons_mediated_deposit_workflow.json")
    end
  end
end
