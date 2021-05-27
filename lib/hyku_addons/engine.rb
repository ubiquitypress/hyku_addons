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
      if Rails.env.development?
        Rails.application.configure do
          config.eager_load = true
        end
      end
    end

    config.before_initialize do
      HykuAddons::I18nMultitenant.configure(I18n)
    end

    initializer "hyku_addons.settings" do
      # Undefine Settings constant to allow for per-thread settings using Settings singleton
      Object.send(:remove_const, Config.const_name) if Object.const_defined?(Config.const_name)
      Settings.switch!
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
          Settings.switch!(name: locale_name, settings: settings)
          switch_host!(cname)
        end

        def reset!
          SolrEndpoint.reset!
          FcrepoEndpoint.reset!
          RedisEndpoint.reset!
          DataCiteEndpoint.reset!
          Settings.switch!
          switch_host!(nil)
        end

        def switch_host!(cname)
          Rails.application.routes.default_url_options[:host] = cname
          Hyrax::Engine.routes.default_url_options[:host] = cname
        end
      end

      Hyku::RegistrationsController.class_eval do
        def new
          return super if current_account&.allow_signup == "true"
          redirect_to root_path, alert: t(:'hyku.account.signup_disabled')
        end

        def create
          return super if current_account&.allow_signup == "true"
          redirect_to root_path, alert: t(:'hyku.account.signup_disabled')
        end

        def current_account
          Site.account
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
                                            settings: %i[file_size_limit locale_name])
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
        APP_GENERATORS = ['HykuAddons::InstallGenerator', 'Hyrax::DOI::InstallGenerator', 'Hyrax::DOI::AddToWorkTypeGenerator', 'Hyrax::Hirmeos::InstallGenerator'].freeze

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

    # NOTE: This issue only seems to present in development, and not consistently.
    # Compact the available work types to remove `nil` and prevent an `Nil location provided. Can't build URI.` error
    # when not all options are selected, thrown from `SelectTypePresenter#switch_to_new_work_path`
    initializer 'hyku_addon.available_work_type_bug_fix' do
      Hyrax::QuickClassificationQuery.class_eval do
        def normalized_model_names
          models.map { |name| concern_name_normalizer.call(name) if Site.first.available_works.include?(name) }.compact
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

    # Allow flipflop to load config/features.rb from the Hyrax gem:
    initializer 'configure' do
      Flipflop::FeatureLoader.current.append(self)
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

    initializer 'hyku_addons.bulkrax_overrides' do
      Bulkrax.setup do |config|
        config.system_identifier_field = 'id'
        config.reserved_properties -= ['depositor']
        config.parsers += [{ class_name: "HykuAddons::CsvParser", name: "Ubiquity Repositiories Hyku 1 CSV", partial: "csv_fields" }]
        config.field_mappings["HykuAddons::CsvParser"] = {
          "institution" => { split: true },
          "org_unit" => { split: true },
          "fndr_project_ref" => { split: true },
          "project_name" => { split: true },
          "rights_holder" => { split: true },
          "library_of_congress_classification" => { split: true },
          "alt_title" => { split: true },
          "volume" => { split: true },
          "duration" => { split: true },
          "version" => { split: true },
          "publisher" => { split: true },
          "keyword" => { split: true },
          "license" => { split: '\|', parsed: true },
          "subject" => { split: true, parsed: true },
          "language" => { split: true, parsed: true },
          "resource_type" => { split: true, parsed: false },
          "date_published" => { split: true, parsed: true }
        }
      end

      Bulkrax::ObjectFactory.class_eval do
        def run
          arg_hash = { id: attributes[:id], name: 'UPDATE', klass: klass }
          @object = find
          if object
            object.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX if object.respond_to? :reindex_extent
            ActiveSupport::Notifications.instrument('import.importer', arg_hash) { update }
          else
            ActiveSupport::Notifications.instrument('import.importer', arg_hash.merge(name: 'CREATE')) { create }
          end
          yield(object) if block_given?
          object
        end

        # An ActiveFedora bug when there are many habtm <-> has_many associations means they won't all get saved.
        # https://github.com/projecthydra/active_fedora/issues/874
        # 2+ years later, still open!
        def create
          attrs = create_attributes
          @object = klass.new
          object.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX if object.respond_to? :reindex_extent
          run_callbacks :save do
            run_callbacks :create do
              if klass == ::AdminSet
                create_admin_set(attrs)
              elsif klass == ::Collection
                create_collection(attrs)
              else
                work_actor.create(environment(attrs))
              end
            end
          end
          log_created(object)
        end

        def update
          raise "Object doesn't exist" unless object
          destroy_existing_files if @replace_files && (klass != ::Collection || klass != ::AdminSet)
          attrs = update_attributes
          run_callbacks :save do
            if klass == ::AdminSet
              update_admin_set(attrs)
            elsif klass == ::Collection
              update_collection(attrs)
            else
              work_actor.update(environment(attrs))
            end
          end
          log_updated(object)
        end

        def create_admin_set(attrs)
          attrs.delete('collection_type_gid')
          object.members = members
          object.attributes = attrs
          object.save!
        end

        def update_admin_set(attrs)
          attrs.delete('collection_type_gid')
          object.members = members
          object.attributes = attrs
          object.save!
        end

        def find
          return find_by_id if attributes[:id]
          return search_by_identifier if attributes[system_identifier_field].present?
          return search_by_title_or_identifier if klass == AdminSet && attributes[:title].present?
        end

        def search_by_title_or_identifier
          AdminSet.where(title: Array(attributes[:title]).first).first || AdminSet.where(id: Array(attributes[:title]).first).first
        end

        def permitted_attributes
          klass.properties.keys.map(&:to_sym) + %i[id edit_users edit_groups read_groups visibility work_members_attributes admin_set_id]
        end

        # Override if we need to map the attributes from the parser in
        # a way that is compatible with how the factory needs them.
        def transform_attributes
          if klass == ::Collection || klass == ::AdminSet
            attributes.slice(*permitted_attributes)
          else
            attributes.slice(*permitted_attributes).merge(file_attributes)
          end
        end
      end

      # FIXME: This might only be important for debugging
      # Bulkrax::ImportWorkJob.class_eval do
      #   def perform(*args)
      #     entry = Bulkrax::Entry.find(args[0])
      #     importer_run = Bulkrax::ImporterRun.find(args[1])
      #     begin
      #       entry.build
      #     rescue Bulkrax::CollectionsCreatedError => e
      #       byebug
      #       # Don't retry on error of collection not created because it goes into an infinite loop
      #       # A failed record is much better
      #       entry.status_info(e)
      #     end

      #     if entry.status == "Complete"
      #       importer_run.increment!(:processed_records)
      #     else
      #       # do not retry here because whatever parse error kept you from creating a work will likely
      #       # keep preventing you from doing so.
      #       importer_run.increment!(:failed_records)
      #     end
      #     entry.save!
      #     return if importer_run.enqueued_records.positive?
      #     if importer_run.failed_records.positive?
      #       importer_run.importer.status_info('Complete (with failures)')
      #     else
      #       importer_run.importer.status_info('Complete')
      #     end
      #   end
      # end
    end

    initializer 'hyku_addons.import_mode_overrides' do
      Hyrax::Actors::FileSetActor.class_eval do
        def attach_to_work(work, file_set_params = {})
          acquire_lock_for(work.id) do
            # Ensure we have an up-to-date copy of the members association, so that we append to the end of the list.
            work.reload unless work.new_record?
            unless assign_visibility?(file_set_params)
              # Work around lack of functionality in bulkrax by bringing all file sets in as private
              # then change visibility post-import
              file_set.visibility = Flipflop.enabled?(:import_mode) ? 'restricted' : work.visibility
            end
            work.ordered_members << file_set
            work.representative = file_set if work.representative_id.blank?
            work.thumbnail = file_set if work.thumbnail_id.blank?
            # Save the work so the association between the work and the file_set is persisted (head_id)
            # NOTE: the work may not be valid, in which case this save doesn't do anything.
            work.save
            Hyrax.config.callback.run(:after_create_fileset, file_set, user)

            # Perform TaskMaster related filset callback
            Hyrax.config.callback.run(:task_master_after_create_fileset, file_set, user)
          end
        end
      end
    end

    initializer 'hyku_addons.hyrax_identifier_overrides' do
      Hyrax::Identifier::Dispatcher.class_eval do
        def assign_for(object:, attribute: :identifier)
          record = registrar.register!(object: object)
          object.public_send("#{attribute}=".to_sym, Array.wrap(record.identifier))
          object
        end
      end
    end

    initializer 'hyku_addons.hyrax_admin_set_create_overrides' do
      Hyrax::Admin::AdminSetsController.class_eval do
        def create_admin_set
          admin_set_create_service.call(admin_set: @admin_set, creating_user: nil)
        end
      end
    end

    initializer 'hyku_addons.session_storage_overrides' do
      Rails.application.config.session_store :cookie_store, key: '_hyku_session', same_site: :lax
    end

    initializer 'hyku_addons.license_renderer_override' do
      # Override to explicitly call our license service with model
      Hyrax::Renderers::LicenseAttributeRenderer.class_eval do
        def attribute_value_to_html(value)
          begin
            parsed_uri = URI.parse(value)
          rescue URI::InvalidURIError
            nil
          end
          license_service = HykuAddons::LicenseService.new(model: options[:work_type]&.safe_constantize)
          has_term = license_service.active_elements.pluck("id").include?(value)
          if parsed_uri.nil? || !has_term
            ERB::Util.h(value)
          else
            %(<a href=#{ERB::Util.h(value)} target="_blank">#{license_service.label(value)}</a>)
          end
        end
      end
    end

    # Pre-existing Work type overrides
    config.after_initialize do
      # Avoid media pluralizing to medium
      ActiveSupport::Inflector.inflections(:en) do |inflect|
        inflect.irregular 'media', 'medias'
      end

      Hyrax.config do |config|
        # Injected via `rails g hyrax:work HykuAddons::Article`
        config.register_curation_concern :article
        config.register_curation_concern :book
        config.register_curation_concern :book_contribution
        config.register_curation_concern :conference_item
        config.register_curation_concern :dataset
        config.register_curation_concern :exhibition_item
        config.register_curation_concern :report
        config.register_curation_concern :time_based_media
        config.register_curation_concern :thesis_or_dissertation
        config.register_curation_concern :pacific_article
        config.register_curation_concern :pacific_book
        config.register_curation_concern :pacific_image
        config.register_curation_concern :pacific_thesis_or_dissertation
        config.register_curation_concern :pacific_book_chapter
        config.register_curation_concern :pacific_media
        config.register_curation_concern :pacific_news_clipping
        config.register_curation_concern :pacific_presentation
        config.register_curation_concern :pacific_text_work
        config.register_curation_concern :pacific_uncategorized
        config.register_curation_concern :redlands_article
        config.register_curation_concern :redlands_book
        config.register_curation_concern :redlands_chapters_and_book_section
        config.register_curation_concern :redlands_conferences_reports_and_paper
        config.register_curation_concern :redlands_open_educational_resource
        config.register_curation_concern :redlands_media
        config.register_curation_concern :redlands_student_work
        config.register_curation_concern :uva_work

        config.license_service_class = HykuAddons::LicenseService

        # FIXME: This setting is global and affects all tenants
        config.work_requires_files = false

        config.callback.enable :task_master_after_create_fileset

        config.callback.set(:task_master_after_create_fileset) do |file_set, _user|
          HykuAddons::TaskMaster::PublishJob.perform_later(
            file_set.task_master_type,
            "upsert",
            file_set.to_task_master.to_json
          )
        end
      end
    end

    # Pre-existing Work type overrides and dynamic includes
    def self.dynamically_include_mixins
      GenericWork.include HykuAddons::GenericWorkOverrides
      Image.include HykuAddons::ImageOverrides
      GenericWork.include ::Hyrax::BasicMetadata
      Hyrax::WorkIndexer.include HykuAddons::WorkIndexerBehavior
      Hyrax::GenericWorkForm.include HykuAddons::GenericWorkFormOverrides
      Hyrax::ImageForm.include HykuAddons::ImageFormOverrides
      Hyrax::Forms::CollectionForm.include HykuAddons::CollectionFormBehavior
      Hyrax::CollectionPresenter.include HykuAddons::CollectionPresenterBehavior
      SolrDocument.include HykuAddons::SolrDocumentBehavior
      SolrDocument.include HykuAddons::SolrDocumentRis
      Hyrax::GenericWorkPresenter.include HykuAddons::GenericWorkPresenterBehavior
      Hyrax::ImagePresenter.include HykuAddons::GenericWorkPresenterBehavior
      CatalogController.include HykuAddons::CatalogControllerBehavior
      Hyrax::CurationConcern.actor_factory.insert_before Hyrax::Actors::ModelActor, HykuAddons::Actors::JSONFieldsActor
      Hyrax::CurationConcern.actor_factory.insert_before Hyrax::Actors::ModelActor, HykuAddons::Actors::DateFieldsActor
      actors = [Hyrax::Actors::DefaultAdminSetActor, HykuAddons::Actors::MemberCollectionFromAdminSetActor]
      Hyrax::CurationConcern.actor_factory.insert_after(*actors)

      # TaskMaster
      Account.include HykuAddons::TaskMaster::AccountBehavior
      FileSet.include HykuAddons::TaskMaster::FileSetBehavior
      # Insert at the end of the actor chain
      Hyrax::CurationConcern.actor_factory.use HykuAddons::Actors::TaskMaster::WorkActor

      User.include HykuAddons::UserEmailFormat
      Bulkrax::Entry.include HykuAddons::BulkraxEntryBehavior
      Bolognese::Writers::RisWriter.include Bolognese::Writers::RisWriterBehavior
      Bolognese::Metadata.prepend Bolognese::Writers::HykuAddonsWorkFormFieldsWriter
      Hyrax::GenericWorksController.include HykuAddons::WorksControllerBehavior
      Hyrax::DOI::HyraxDOIController.include HykuAddons::DOIControllerBehavior
      ::ApplicationController.include ::HykuAddons::MultitenantLocaleControllerBehavior # ::HykuAddons... is required
      ::Hyku::API::V1::FilesController.include HykuAddons::FilesControllerBehavior
      ::ActiveJob::Base.include HykuAddons::ImportMode
      Hyrax::Dashboard::ProfilesController.prepend HykuAddons::Dashboard::ProfilesControllerBehavior

      User.include Hyrax::UserBehavior
      Hyrax::CurationConcern.actor_factory.use Hyrax::Actors::OrcidActor
      Bolognese::Metadata.prepend Bolognese::Writers::OrcidXmlWriter
    end

    # Use #to_prepare because it reloads where after_initialize only runs once
    # This might slow down every request so only do it in development environment
    if Rails.env.development?
      config.to_prepare { HykuAddons::Engine.dynamically_include_mixins }
    else
      config.after_initialize { HykuAddons::Engine.dynamically_include_mixins }
      # This is needed to allow the API search to copy the blacklight configuration after our customisations are applied.
      initializer 'hyku_addons.blacklight_config override' do
        CatalogController.include HykuAddons::CatalogControllerBehavior
      end
    end
  end
end
