# frozen_string_literal: true
require 'hyrax/doi/engine'
require 'bolognese/metadata'

module HykuAddons
  class Engine < ::Rails::Engine
    isolate_namespace HykuAddons

    config.before_initialize do
      # Eager load required for overrides in the initializer below
      # There is probably a better solution for this but I don't think it is worth the time
      # tinkering with it since this works and doesn't cause too much of a slowdown
      if Rails.env == 'development' # Only do this for development environment for now
        Rails.application.configure do
          config.eager_load = true
        end
      end
    end

    initializer 'hyku_addons.class_overrides_for_hyrax-doi' do
      require_dependency 'hyrax/search_state'

      # Cannot do prepend here because it causes it to get loaded before AcitveRecord breaking things
      Account.class_eval do
        include HykuAddons::AccountBehavior

        # @return [Account] a placeholder account using the default connections configured by the application
        def self.single_tenant_default
          Account.new do |a|
            a.build_solr_endpoint
            a.build_fcrepo_endpoint
            a.build_redis_endpoint
            a.build_datacite_endpoint
          end
        end

        # Make all the account specific connections active
        def switch!
          solr_endpoint.switch!
          fcrepo_endpoint.switch!
          redis_endpoint.switch!
          datacite_endpoint.switch!
        end

        def reset!
          SolrEndpoint.reset!
          FcrepoEndpoint.reset!
          RedisEndpoint.reset!
          DataCiteEndpoint.reset!
        end
      end

      # Using a concern doesn't actually override the original method so inlining it here
      Proprietor::AccountsController.include HykuAddons::AccountControllerBehavior
      Proprietor::AccountsController.class_eval do
        private

          # Never trust parameters from the scary internet, only allow the allowed list through.
          def account_params
            params.require(:account).permit(:name, :cname, :title,
                                            admin_emails: [],
                                            solr_endpoint_attributes: %i[id url],
                                            fcrepo_endpoint_attributes: %i[id url base_path],
                                            datacite_endpoint_attributes: %i[mode prefix username password],
                                            settings: [:file_size_limit])
          end
      end

      CreateAccount.class_eval do
        def create_account_inline
          CreateAccountInlineJob.perform_now(account) && account.create_datacite_endpoint
        end
      end
    end

    config.after_initialize do
      # Prepend our views so they have precedence
      ActionController::Base.prepend_view_path(paths['app/views'].existent)
      # Append our locales so they have precedence
      I18n.load_path += Dir[HykuAddons::Engine.root.join('config', 'locales', '*.{rb,yml}')]

      # # Append per-tenant settings to dashboard
      # Hyrax::DashboardController.class_eval do
      #   class_attribute :sidebar_partials
      #   self.sidebar_partials = {}
      # end
      # Hyrax::DashboardController.sidebar_partials[:configuration] ||= []
      # Hyrax::DashboardController.sidebar_partials[:configuration] << "hyrax/dashboard/sidebar/per_tenant_settings"
    end

    ## In engine development mode (ENGINE_ROOT defined) handle specific generators as app-only by setting destintation_root appropriately
    initializer 'hyku_addons.app_generators' do
      if defined?(ENGINE_ROOT)
        APP_GENERATORS = ['HykuAddons::InstallGenerator', 'Hyrax::DOI::InstallGenerator', 'Hyrax::DOI::AddToWorkTypeGenerator'].freeze

        Rails::Generators::Base.class_eval do
          def initialize(args, options, config)
            # Force the destination root to be the rails application and not this engine when doing development
            # See https://github.com/rails/rails/blob/fb852668dff2786a4cfb30ad923830da9eed2476/railties/lib/rails/commands/generate/generate_command.rb#L26
            # and https://github.com/rails/rails/blob/9d44519afc5290eab8479db851f09653cf0a916f/railties/lib/rails/command.rb#L75-L82

            config[:destination_root] = Pathname.new(File.expand_path("../..", APP_PATH)) if self.class.name.in?(APP_GENERATORS)
            super
          end
        end
      end
    end

    # Add migrations to parent app paths
    initializer 'hyku_addons.append_migrations' do |app|
      Hyku::Application.default_url_options[:host] = 'lvh.me:3000'
      unless app.root.to_s.match?(root.to_s)
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end

    # In test & dev environments, dynamically mount the hyku_addons in the parent app to avoid routing errors
    config.after_initialize do
      if Rails.env == 'development' || Rails.env == 'test'
        # Resolves Missing host to link to! Please provide the :host parameter, set default_url_options[:host], or set :only_path to true
        HykuAddons::Engine.routes.default_url_options = { host: 'lvh.me:3000' }
      end
    end

    # Automount this engine
    # Only do this because this is just for us and we don't need to allow control over the mount to the application
    config.after_initialize do
      Rails.application.routes.prepend do
        mount HykuAddons::Engine => '/'
      end
    end

    # HACK: Workaround issue where Flipflop's db table needs to be created before db:create has been run
    # This is because we're prepending to Hyrax::GenericWorksController which forces a load of Hyrax::WorksControllerBehavior
    # which calls Flipflop in an `included` block.
    # See https://github.com/samvera/hyrax/blob/v2.9.1/app/controllers/concerns/hyrax/works_controller_behavior.rb#L17
    initializer 'hyku_addons.workaround_flip_flop' do
      Flipflop::Facade.module_eval do
        def method_missing(method, *args)
          if method[-1] == "?"
            return false unless ActiveRecord::Base.connected? && ActiveRecord::Base.connection.table_exists?(:hyrax_features)
            Flipflop::FeatureSet.current.enabled?(method[0..-2].to_sym)
          else
            super
          end
        end
      end
    end

    # Pre-existing Work type overrides
    config.after_initialize do
      Hyrax.config do |config|
        # Injected via `rails g hyrax:work HykuAddons::Article`
        config.register_curation_concern :article
        config.register_curation_concern :book_contribution
        config.register_curation_concern :conference_item
        config.register_curation_concern :time_based_media_article
      end
    end

    # Pre-existing Work type overrides and dynamic includes
    def self.dynamically_include_mixins
      GenericWork.include HykuAddons::GenericWorkOverrides
      GenericWork.include ::Hyrax::BasicMetadata
      WorkIndexer.include HykuAddons::WorkIndexerBehavior
      Hyrax::GenericWorkForm.include HykuAddons::GenericWorkFormOverrides
      SolrDocument.include HykuAddons::SolrDocumentBehavior
      SolrDocument.include HykuAddons::SolrDocumentRis
      Hyrax::GenericWorkPresenter.include HykuAddons::GenericWorkPresenterBehavior
      CatalogController.include HykuAddons::CatalogControllerBehavior
      Hyrax::CurationConcern.actor_factory.insert_before Hyrax::Actors::ModelActor, HykuAddons::Actors::JSONFieldsActor
      Hyrax::CurationConcern.actor_factory.insert_before Hyrax::Actors::ModelActor, HykuAddons::Actors::DateFieldsActor
      Hyrax::GenericWorksController.prepend HykuAddons::WorksControllerAdditionalMimeTypesBehavior
    end

    # Use #to_prepare because it reloads where after_initialize only runs once
    # This might slow down every request so only do it in development environment
    if Rails.env == 'development'
      config.to_prepare { HykuAddons::Engine.dynamically_include_mixins }
    else
      config.after_initialize { HykuAddons::Engine.dynamically_include_mixins }
    end
  end
end
