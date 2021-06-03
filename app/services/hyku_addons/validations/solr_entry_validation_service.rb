# frozen_string_literal: true

module HykuAddons
  module Validations
    class SolrEntryValidationService < EntryValidationService
      attr_reader :errors, :entry

      SOURCE_SERVICE_OPTIONS = {
        base_url: ENV['BULKRAX_SOURCE_BASE_URL'],
        username: ENV['BULKRAX_SOURCE_USERNAME'],
        password: ENV['BULKRAX_SOURCE_PASSWORD']
      }.with_indifferent_access.freeze

      DESTINATION_SERVICE_OPTIONS = {
        base_url: ENV['BULKRAX_DESTINATION_BASE_URL'],
        username: ENV['BULKRAX_DESTINATION_USERNAME'],
        password: ENV['BULKRAX_DESTINATION_PASSWORD']
      }.with_indifferent_access.freeze

      EXCLUDED_FIELDS = %i[
        _version_ timestamp thumbnail_path_ss date_modified_dtsi system_create_dtsi system_modified_dtsi
        accessControl_ssim abstract_oai_tesim account_cname_tesim actionable_workflow_roles_ssim disable_draft_doi_tesim
        nesting_collection__deepest_nested_depth_isi nesting_collection__pathnames_ssim official_link_tesim doi_oai_tesim
        draft_doi_tesim file_availability_tesim work_tenant_url_tesim edit_access_person_ssim
        nesting_collection__ancestors_ssim nesting_collection__parent_ids_ssim hasEmbargo_ssim hasLease_ssim
        migration_id_tesim buy_book_tesim irb_number_tesim irb_status_tesim hasRelatedImage_ssim
        hasRelatedMediaFragment_ssim file_set_ids_ssim member_ids_ssim
      ].freeze

      RENAMED_FIELDS = {
        creator_search_tesim: "creator_display_ssim",
        contributor_list_tesim: "contributor_display_ssim",
        date_uploaded_dtsi: 'date_uploaded_ssi',
        version_tesim: 'version_number_tesim',
        collection_id_tesim: 'member_of_collection_ids_ssim',
        collection_names_tesim: 'member_of_collections_ssim',
        doi_tesim: 'official_link'
      }.with_indifferent_access.freeze

      EXCLUDED_FIELDS_WITH_VALUES = {
        edit_access_group_ssim: ["admin"]
      }.with_indifferent_access.freeze

      def initialize(account, entry, source_service_options = nil, destination_service_options = nil)
        super(account, entry)

        source_service_options ||= {}
        destination_service_options ||= {}
        @source_base_url = source_service_options[:base_url] || SOURCE_SERVICE_OPTIONS[:base_url]
        @source_username = source_service_options[:username] || SOURCE_SERVICE_OPTIONS[:username]
        @source_password = source_service_options[:password] || SOURCE_SERVICE_OPTIONS[:password]
        @source_cookie = source_service_options[:cookie]

        @destination_base_url = destination_service_options[:base_url] || DESTINATION_SERVICE_OPTIONS[:base_url]
        @destination_username = destination_service_options[:username] || DESTINATION_SERVICE_OPTIONS[:username]
        @destination_password = destination_service_options[:password] || DESTINATION_SERVICE_OPTIONS[:password]
        @destination_cookie = destination_service_options[:cookie]

        raise ArgumentError, "Source and destination service params must be present" unless valid_endpoint_params?
      end

      def source_metadata
        @_source_metadata ||=
          begin
            if @source_cookie.present?
              HykuAddons::BlacklightWorkJsonCookieService.new(@source_base_url, @source_cookie).fetch(@entry)
            else
              HykuAddons::BlacklightWorkJsonService.new(@source_base_url, @source_username, @source_password).fetch(@entry)
            end
          end
      end

      protected

        def valid_endpoint_params?
          @source_base_url && ((@source_username && @source_password) || @source_cookie) &&
            @destination_base_url && ((@destination_username && @destination_password) || @destination_cookie)
        end

        COMMON_CONTRIBUTOR_AND_CREATOR_FIELDS = %w[
          organization_name organisation_name given_name middle_name family_name name_type orcid isni ror grid wikidata suffix institution
        ].freeze

        def creator_contributor_reevaluation(prefix, old_value)
          returning_value = []
          old_value.each do |tesim|
            tesim = JSON.parse(tesim)[0]
            COMMON_CONTRIBUTOR_AND_CREATOR_FIELDS.each do |field|
              tesim["#{prefix}_#{field}"] ||= ""
            end
            tesim["#{prefix}_role"] = Array(tesim["#{prefix}_role"].presence)
            tesim["#{prefix}_position"] ||= "0"
            tesim["#{prefix}_institutional_relationship"] = Array(tesim["#{prefix}_institutional_relationship"].presence)
            returning_value.push([tesim].to_json)
          end
          returning_value
        end

        def reevaluate_creator_tesim(old_value)
          creator_contributor_reevaluation(:creator, old_value)
        end

        def reevaluate_contributor_tesim(old_value)
          creator_contributor_reevaluation(:contributor, old_value)
        end

        def reevaluate_date_published_tesim(old_value)
          [Date.parse(old_value[0]).strftime("%Y-%-m-%-d")]
        rescue
          old_value
        end

        def reevaluate_has_model_ssim(old_value)
          ["Pacific#{gross_work_type_name(old_value)}"]
        end

        def reevaluate_human_readable_type_tesim(old_value)
          ["Pacific #{gross_work_type_name(old_value)}"]
        end

        def reevaluate_admin_set_tesim(old_value)
          Array.wrap(old_value).first == "Default Admin Set" ? ['Default'] : old_value
        end

        def reevaluate_resource_type_tesim(old_value)
          initial_value = Array.wrap(old_value).first
          case initial_value
          when "ImageWork Image"
            "Image"
          when "ArticleWork Default Article"
            "Article"
          when "Media default Media"
            "Media"
          when "TextWork default Text"
            "Text"
          when "Media Audio"
            "Audio"
          when "BookWork Book"
            "Book"
          when "BookChapter default Book chapter"
            "Book Chapter"
          when "ThesisOrDissertationWork default Thesis"
            "Thesis"
          when "Presentation default Presentation"
            "Presentation"
          when "Uncategorized default Uncategorized"
            "Uncategorized"
          when /Capstone/
            "Capstone"
          when /Creative Work/
            "Creative Work"
          when /Essay/
            "Dissertation"
          when /Grant/
            "Grant"
          when /Handbook/
            "Handbook"
          when /Letter/
            "Letter"
          when /Research/
            "Research article"
          when /Review/
            "Review article"
          when /Editorial/
            "Editorial"
          when /Dissertation/
            "Dissertation"
          when /Application/
            "Application"
          when /Intellectual/
            "Intellectual Freedom News"
          else
            initial_value
          end
        end

        def gross_work_type_name(alt_name)
          alt_name.first.gsub(/Pacific|Work|\s*/, '')
        end
    end
  end
end
