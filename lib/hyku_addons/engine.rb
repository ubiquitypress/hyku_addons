# frozen_string_literal: true

require "hyrax/form_fields"
require "hyrax/indexer"
require "hyrax/schema"
require "hyrax/simple_schema_loader"
require "hyrax/doi/engine"
require "bolognese/metadata"
require "cocoon"
require "hyrax/autopopulation/engine"

module HykuAddons
  class Engine < ::Rails::Engine
    isolate_namespace HykuAddons

    # Without this include, the presenter will be dropped by the autoloader each time a change is made. Because of the
    # way the app is structured, we need to include it here to have the console and server use the same location.
    require HykuAddons::Engine.root.join("app/presenters/hyku_addons/schema/presenter.rb")

    config.before_initialize do
      # Eager load required for overrides in the initializer below
      # There is probably a better solution for this but I don't think it is worth the time
      # tinkering with it since this works and doesn't cause too much of a slowdown
      Rails.application.configure { config.eager_load = true } if Rails.env.development?

      HykuAddons::I18nMultitenant.configure(I18n)
    end

    config.after_initialize do
      # Prepend our views so they have precedence
      ActionController::Base.prepend_view_path(paths["app/views"].existent)

      # Append our locales so they have precedence
      I18n.load_path += Dir[HykuAddons::Engine.root.join("config", "locales", "*.{rb,yml}")]

      # In test & dev environments, dynamically mount the hyku_addons in the parent app to avoid routing errors
      # Resolves Missing host to link to! Please provide the :host parameter,
      # set default_url_options[:host], or set :only_path to true
      HykuAddons::Engine.routes.default_url_options = { host: "hyku.docker" } unless Rails.env.production?

      # Automount the engine
      Rails.application.routes.prepend { mount HykuAddons::Engine => "/" }

      # Remove the Hyrax Orcid JSON Actor as we have our own - this should not be namespaced
      Hyrax::CurationConcern.actor_factory.middlewares.delete(Hyrax::Actors::Orcid::JSONFieldsActor)

      # Remove the Hyrax Orcid pipeline as its not required within HykuAddons
      ::Blacklight::Rendering::Pipeline.operations.delete(Hyrax::Orcid::Blacklight::Rendering::PipelineJsonExtractor)
    end

    # Add migrations to parent app paths
    # NOTE: This could be placed in an initializer file, but with some difficulty,
    # so as it is engine specific I have opted to leave it inplace.
    initializer "hyku_addons.append_migrations" do |app|
      unless app.root.to_s.match?(root.to_s)
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    # This is the recommended way of loading Engine features and cannot be moved to an
    # initializer without causing a number of stange errors when the Rails server starts
    # or dropped features in development
    initializer "flipflop.configure" do
      Flipflop::FeatureLoader.current.append(self)
    end

    initializer "hyku_addons.session_storage_overrides" do
      Rails.application.config.session_store :cookie_store, key: "_hyku_session", same_site: :lax
    end

    # Monkey-patch override to make use of file set parameters relating to permissions
    # See https://github.com/samvera/hyrax/pull/4992
    initializer "hyku_addons.file_set_overrides" do
      AttachFilesToWorkJob.class_eval do
        # @param [ActiveFedora::Base] work - the work object
        # @param [Array<Hyrax::UploadedFile>] uploaded_files - an array of files to attach
        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def perform(work, uploaded_files, **work_attributes)
          validate_files!(uploaded_files)
          depositor = proxy_or_depositor(work)
          user = User.find_by_user_key(depositor)
          work_permissions = work.permissions.map(&:to_hash)

          uploaded_files.each do |uploaded_file|
            next if uploaded_file.file_set_uri.present?

            actor = Hyrax::Actors::FileSetActor.new(FileSet.create, user)
            file_set_attributes = file_set_attrs(work_attributes, uploaded_file)
            metadata = visibility_attributes(work_attributes, file_set_attributes)
            uploaded_file.update(file_set_uri: actor.file_set.uri)
            actor.file_set.permissions_attributes = work_permissions
            # NOTE: The next line is not included in the upstream PR
            # This line allows the setting of a file's title from a bulkrax import
            actor.file_set.title = Array(file_set_attributes[:title].presence)
            actor.create_metadata(metadata)
            actor.create_content(uploaded_file)
            actor.attach_to_work(work, metadata)
          end
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        private

          # The attributes used for visibility - sent as initial params to created FileSets.
          def visibility_attributes(attributes, file_set_attributes)
            attributes.merge(Hash(file_set_attributes).symbolize_keys).slice(:visibility, :visibility_during_lease,
                                                                             :visibility_after_lease, :lease_expiration_date,
                                                                             :embargo_release_date, :visibility_during_embargo,
                                                                             :visibility_after_embargo)
          end

          def file_set_attrs(attributes, uploaded_file)
            attrs = Array(attributes[:file_set]).find { |fs| fs[:uploaded_file_id].present? && (fs[:uploaded_file_id].to_i == uploaded_file&.id) }
            Hash(attrs).symbolize_keys
          end
      end
    end

    initializer "hyku_addons.hyrax_admin_set_create_overrides" do
      Hyrax::Admin::AdminSetsController.class_eval do
        def create_admin_set
          admin_set_create_service.call(admin_set: @admin_set, creating_user: nil)
        end
      end
    end

    # HykuAddons mixins, monkey patches and modules overrides
    #
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def self.mixins
      # Actors
      # NOTE: The order of the insert before/after must be preserved
      Hyrax::CurationConcern.actor_factory.use HykuAddons::Actors::TaskMaster::WorkActor
      Hyrax::CurationConcern.actor_factory.insert_before Hyrax::Actors::ModelActor, HykuAddons::Actors::JSONFieldsActor
      Hyrax::CurationConcern.actor_factory.insert_before Hyrax::Actors::ModelActor, HykuAddons::Actors::DateFieldsActor
      Hyrax::CurationConcern.actor_factory.insert_before Hyrax::Actors::ModelActor, HykuAddons::Actors::NoteFieldActor
      actors = [Hyrax::Actors::ModelActor, HykuAddons::Actors::RelatedIdentifierActor]
      Hyrax::CurationConcern.actor_factory.insert_after(*actors)
      actors = [HykuAddons::Actors::JSONFieldsActor, HykuAddons::Actors::CreatorProfileVisibilityActor]
      Hyrax::CurationConcern.actor_factory.insert_after(*actors)
      actors = [Hyrax::Actors::DefaultAdminSetActor, HykuAddons::Actors::MemberCollectionFromAdminSetActor]
      Hyrax::CurationConcern.actor_factory.insert_after(*actors)
      Hyrax::Actors::FileSetActor.include HykuAddons::Actors::FileSetActorBehavior
      Hyrax::Actors::BaseActor.prepend HykuAddons::Actors::BaseActorBehavior

      # Bolognese
      ::Bolognese::Writers::RisWriter.include ::Bolognese::Writers::RisWriterBehavior
      ::Bolognese::Metadata.prepend ::Bolognese::Writers::HykuAddonsWorkFormFieldsWriter
      ::Bolognese::Metadata.include ::Bolognese::Readers::HykuAddonsWorkReader
      ::Bolognese::Metadata.prepend ::Bolognese::Writers::HyraxWorkWriterBehavior
      ::Bolognese::Metadata.include HykuAddons::Bolognese::JsonFieldsReader

      # Bulkrax
      ::Bulkrax::Entry.include HykuAddons::BulkraxEntryBehavior
      ::Bulkrax::ObjectFactory.prepend HykuAddons::Bulkrax::ObjectFactoryBehavior
      ::Bulkrax::ImportersController.include HykuAddons::ImporterControllerBehavior
      ::Bulkrax::ExportersController.include HykuAddons::ExportersControllerOverride

      # Controllers
      Hyrax::GenericWorksController.include HykuAddons::WorksControllerBehavior
      Hyrax::DOI::HyraxDOIController.include HykuAddons::DOIControllerBehavior
      Proprietor::AccountsController.include HykuAddons::AccountControllerBehavior
      ::ApplicationController.include HykuAddons::MultitenantLocaleControllerBehavior
      ::Hyku::RegistrationsController.include HykuAddons::RegistrationsControllerBehavior
      ::Hyrax::Dashboard::ProfilesController.prepend HykuAddons::ProfilesControllerBehavior
      ::ApplicationController.prepend HykuAddons::ApplicationControllerOverride
      ::Hyrax::Admin::FeaturesController.prepend HykuAddons::FlipflopFeaturesControllerOverride
      ::Flipflop::StrategiesController.prepend HykuAddons::FlipflopStrategiesControllerOverride
      ::Proprietor::AccountsController.prepend HykuAddons::ProprietorControllerOverride
      ::Hyrax::StatsController.include HykuAddons::StatsControllerBehavior
      Hyrax::GenericWorkPresenter.include HykuAddons::GenericWorkPresenterBehavior
      Hyrax::ImagePresenter.include HykuAddons::GenericWorkPresenterBehavior
      CatalogController.include HykuAddons::CatalogControllerBehavior

      # Forms
      Hyrax::GenericWorkForm.include HykuAddons::GenericWorkFormOverrides
      Hyrax::ImageForm.include HykuAddons::ImageFormOverrides
      Hyrax::Forms::CollectionForm.include HykuAddons::CollectionFormBehavior

      # Hyku API
      ::Hyku::API::V1::SearchController.prepend HykuAddons::SearchControllerBehavior
      ::Hyku::API::V1::FilesController.include HykuAddons::FilesControllerBehavior
      ::Hyku::API::V1::HighlightsController.prepend HykuAddons::HighlightsControllerBehavior
      ::Hyku::API::V1::UsersController.prepend HykuAddons::UsersControllerBehavior

      # Indexers
      ::Hyrax::CollectionIndexer.prepend HykuAddons::CollectionIndexerOverride
      Hyrax::WorkIndexer.include HykuAddons::WorkIndexerBehavior

      # Jobs
      ::ActiveJob::Base.include HykuAddons::ImportMode
      ::CleanupAccountJob.prepend HykuAddons::CleanupAccountJobBehavior
      ::CreateFcrepoEndpointJob.prepend HykuAddons::CreateFcrepoEndpointJobOverride
      ::RemoveSolrCollectionJob.prepend HykuAddons::RemoveSolrCollectionJobOverride
      # Overrides for shared_search, remove when we start using Hyku-3
      ::CreateSolrCollectionJob.prepend HykuAddons::CreateSolrCollectionJobOverride

      # Misc
      ActiveSupport::Cache::Store.prepend HykuAddons::CacheLogger
      Hyrax::Workflow::AbstractNotification.include HykuAddons::WorkflowBehavior
      Mailboxer::MessageMailer.prepend HykuAddons::MailboxerMessageMailerBehavior

      # Models / Records
      Account.include HykuAddons::AccountBehavior
      Account.include HykuAddons::TaskMaster::AccountBehavior
      ::CreateAccount.prepend HykuAddons::CreateAccountOverride
      FileSet.include HykuAddons::TaskMaster::FileSetBehavior
      GenericWork.include HykuAddons::GenericWorkOverrides
      GenericWork.include ::Hyrax::BasicMetadata
      Image.include HykuAddons::ImageOverrides
      SolrDocument.include HykuAddons::SolrDocumentBehavior
      SolrDocument.include HykuAddons::SolrDocumentRis
      User.include HykuAddons::UserBehavior

      # Presenters / Renderers
      Hyrax::CollectionPresenter.include HykuAddons::CollectionPresenterBehavior
      Hyrax::Renderers::LicenseAttributeRenderer.prepend Hyrax::Renderers::LicenseAttributeRendererBehavior
      ::Hyrax::CollectionPresenter.prepend HykuAddons::CollectionPresenterOverride

      # Service Endpoints
      ::SolrEndpoint.prepend HykuAddons::SolrEndpointOverride
      ::NilEndpoint.prepend HykuAddons::NilEndpointOverride

      # Workflows
      Hyrax::Workflow::ChangesRequiredNotification.prepend HykuAddons::Workflow::ChangesRequiredNotification
      Hyrax::Workflow::DepositedNotification.prepend HykuAddons::Workflow::DepositedNotification
      Hyrax::Workflow::PendingReviewNotification.prepend HykuAddons::Workflow::PendingReviewNotification
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # NOTE: The mixins are included differently depending on the environment; for development it allows code reloading;
    # in producution it loads all files when the process starts. This can leave to small differences in how files are
    # included and can, in some circumstances, lead to production only bugs.
    method = Rails.env.development? ? :to_prepare : :after_initialize
    config.send(method) { HykuAddons::Engine.mixins }
  end
end
