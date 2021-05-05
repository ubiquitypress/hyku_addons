# frozen_string_literal: true

module HykuAddons
  class EntryValidationService
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
    #

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

    def initialize(account, entry, source_service_options = {}, destination_service_options = {})
      @account = account
      @entry = entry

      @source_base_url = source_service_options[:base_url] || SOURCE_SERVICE_OPTIONS[:base_url]
      @source_username = source_service_options[:username] || SOURCE_SERVICE_OPTIONS[:username]
      @source_password = source_service_options[:password] || SOURCE_SERVICE_OPTIONS[:password]
      @source_cookie   = source_service_options[:cookie]

      @destination_base_url = destination_service_options[:base_url] || DESTINATION_SERVICE_OPTIONS[:base_url]
      @destination_username = destination_service_options[:username] || DESTINATION_SERVICE_OPTIONS[:username]
      @destination_password = destination_service_options[:password] || DESTINATION_SERVICE_OPTIONS[:password]
      @destination_cookie   = destination_service_options[:cookie]

      raise ArgumentError, "You must pass a valid Account" unless @account.present?
      raise ArgumentError, "You must pass a valid HykuAddons::CsvEntry with  successfully imported items" unless @entry&.status == "Complete"
      raise ArgumentError, "Source and destination service params must be present" unless valid_endpoint_params?
    end

    def validate
      Rails.logger.info "Validating entry #{@entry.id}"
      @errors = left_differences + right_differences + merged_fields_differences
      return true if @errors.empty?

      @errors.each do |error|
        Rails.logger.info "\t#{error}"
      end

      @entry.current_status.update(error_backtrace: @errors)
      false
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

    def destination_metadata
      @_destination_metadata ||= ActiveFedora::SolrService.get("id:#{@entry.identifier}").dig('response', 'docs')&.first || {}
    end

    def source_metadata_after_transforms
      filtered = processable_fields(source_metadata)
      filtered_and_renamed = rename_fields(filtered)
      reevaluate_fields(filtered_and_renamed)
    end

    def destination_metadata_after_transforms
      reevaluate_fields(processable_fields(destination_metadata))
    end

    def left_differences
      differences = source_metadata_after_transforms.keep_if { |k, v| v.present? && !destination_metadata_after_transforms.key?(k) }
      diff_list_for(differences, :remove)
    end

    def right_differences
      differences = destination_metadata_after_transforms.keep_if { |k, _v| !source_metadata_after_transforms.key?(k) }
      diff_list_for(differences, :add)
    end

    def merged_fields_differences
      differences = destination_metadata_after_transforms.keep_if do |k, v|
        value_at_source = source_metadata_after_transforms[k]
        if value_at_source.present?
          begin
            semantic_comparison(JSON.parse(value_at_source[0]), JSON.parse(v[0]))
          rescue
            value_at_source.present? && semantic_comparison(value_at_source, v)
          end
        end
      end
      diff_list_for(differences, :change)
    end

    protected

      def valid_endpoint_params?
        @source_base_url && ((@source_username && @source_password) || @source_cookie) &&
          @destination_base_url && ((@destination_username && @destination_password) || @destination_cookie)
      end

      def diff_list_for(issues, operation)
        issues.map { |k, v| { path: k, op: operation, value: v } }
      end

      def processable_fields(metadata)
        metadata.select do |k, v|
          !excluded_field?(k) && !excluded_field_with_value?(k, v) && non_empty_list_of_values?(v)
        end
      end

      def excluded_field?(k)
        EXCLUDED_FIELDS.include?(k.to_sym)
      end

      def excluded_field_with_value?(k, v)
        Array(EXCLUDED_FIELDS_WITH_VALUES[k]) == Array(v)
      end

      def non_empty_list_of_values?(v)
        Array.wrap(v).any?(&:present?)
      end

      def rename_fields(metadata)
        RENAMED_FIELDS.each do |k, v|
          metadata[v] = metadata.delete(k)
        end
        metadata
      end

      def semantic_comparison(a, b)
        non_blank_stripped_sets(a) != non_blank_stripped_sets(b)
      end

      def non_blank_stripped_sets(item)
        Array.wrap(item).select(&:present?).map { |i| i.try(:strip)&.downcase || i }.to_set
      end

      def reevaluate_fields(metadata)
        metadata.clone.each do |k, v|
          reeval_method_name = "reevaluate_#{k}"
          next unless methods.include?(reeval_method_name.to_sym) && v.try(:any?)

          new_value = send(reeval_method_name, v)
          metadata[k] = new_value
        end
        metadata
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
          tesim["#{prefix}_institutional_relationship"] =
            Array(tesim["#{prefix}_institutional_relationship"].presence)
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
        when "ImageWork Image" then "Image"
        when "ArticleWork Default Article" then "Article"
        when "Media default Media" then "Media"
        when "TextWork default Text" then "Text"
        when "Media Audio" then "Audio"
        when "BookWork Book" then "Book"
        when "BookChapter default Book chapter" then "Book Chapter"
        when "ThesisOrDissertationWork default Thesis" then "Thesis"
        when "Presentation default Presentation" then "Presentation"
        when "Uncategorized default Uncategorized" then "Uncategorized"
        when /Capstone/ then "Capstone"
        when /Creative Work/ then "Creative Work"
        when /Essay/ then "Dissertation"
        when /Grant/ then "Grant"
        when /Handbook/ then "Handbook"
        when /Letter/ then "Letter"
        when /Research/ then "Research article"
        when /Review/ then "Review article"
        when /Editorial/ then"Editorial"
        when /Dissertation/ then "Dissertation"
        when /Application/ then "Application"
        when /Intellectual/ then "Intellectual Freedom News"
        else
          initial_value
        end
      end

      def gross_work_type_name(alt_name)
        alt_name.first.gsub(/Pacific|Work|\s*/, '')
      end
  end
end
