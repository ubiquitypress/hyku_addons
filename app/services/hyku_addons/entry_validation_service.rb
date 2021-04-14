# frozen_string_literal: true

module HykuAddons
  class EntryValidationService
    attr_reader :errors, :entry

    SOURCE_SERVICE_OPTIONS = {
      base_url: ENV['BULKRAX_SOURCE_BASE_URL'],
      username: ENV['BULKRAX_SOURCE_USERNAME'],
      password: ENV['BULKRAX_SOURCE_PASSWORD']
    }.freeze

    DESTINATION_SERVICE_OPTIONS = {
      base_url: ENV['BULKRAX_DESTINATION_BASE_URL'],
      username: ENV['BULKRAX_DESTINATION_USERNAME'],
      password: ENV['BULKRAX_DESTINATION_PASSWORD']
    }.freeze

    EXCLUDED_FIELDS = %i[
      _version_ timestamp thumbnail_path_ss date_modified_dtsi system_create_dtsi system_modified_dtsi
      accessControl_ssim abstract_oai_tesim account_cname_tesim actionable_workflow_roles_ssim disable_draft_doi_tesim
      nesting_collection__deepest_nested_depth_isi nesting_collection__pathnames_ssim official_link_tesim doi_oai_tesim
      draft_doi_tesim file_availability_tesim work_tenant_url_tesim edit_access_person_ssim
    ].freeze

    RENAMED_FIELDS = {
      creator_search_tesim: "creator_display_ssim",
      contributor_list_tesim: "contributor_display_ssim",
      date_uploaded_dtsi: 'date_uploaded_ssi',
      version_tesim: 'version_number_tesim'
    }.with_indifferent_access.freeze

    def initialize(account, entry, source_service_options = {}, destination_service_options = {})
      @account = account
      @entry = entry
      @source_base_url = source_service_options[:base_url] || SOURCE_SERVICE_OPTIONS[:base_url]
      @source_username = source_service_options[:username] || SOURCE_SERVICE_OPTIONS[:username]
      @source_password = source_service_options[:password] || SOURCE_SERVICE_OPTIONS[:password]

      @destination_base_url = destination_service_options[:base_url] || DESTINATION_SERVICE_OPTIONS[:base_url]
      @destination_username = destination_service_options[:username] || DESTINATION_SERVICE_OPTIONS[:username]
      @destination_password = destination_service_options[:password] || DESTINATION_SERVICE_OPTIONS[:password]

      raise ArgumentError, "You must pass a valid HykuAddons::CsvEntry" unless @entry.present?
      raise ArgumentError, "Source and destination service params must be present" unless valid_endpoint_params?
    end

    def validate
      @errors = left_join_differences + right_join_differences + common_fields_differences
      return true if @errors.empty?

      @entry.statuses.create!(
        status_message: 'Validation Error',
        runnable: @entry.last_run,
        error_message: 'Metadata validation failed',
        error_backtrace: @errors
      )
      false
    end

    def source_metadata
      # @_source_metadata ||= HykuAddons::BlacklightWorkJsonService.new(@source_base_url, @source_username, @source_password).fetch(@entry)
      @_source_metadata ||= HykuAddons::BlacklightWorkJsonCookieService.new(@source_base_url, ENV["BULKRAX_SOURCE_COOKIE"]).fetch(@entry)
    end

    def destination_metadata
      # @_destination_metadata ||= @account.solr_endpoint.connection.get( 'select', :params => {:q => "id:#{@entry.identifier}", fl: '*'})['response']['docs'][0]
      @_destination_metadata ||= ActiveFedora::SolrService.get("id:#{@entry.identifier}").dig('response', 'docs')&.first || {}
      # @_destination_metadata ||= HykuAddons::BlacklightWorkJsonService.new(@destination_base_url, @destination_username, @destination_password).fetch(@entry)
    end

    def source_metadata_after_transforms
      filtered = filter_out_excluded_fields(source_metadata)
      filtered_and_renamed = rename_fields(filtered)
      reevaluate_fields(filtered_and_renamed)
    end

    def destination_metadata_after_transforms
      reevaluate_fields(filter_out_excluded_fields(destination_metadata))
    end

    def left_join_differences
      left_differences = source_metadata_after_transforms.keep_if { |k, v| v.present? && !destination_metadata_after_transforms.key?(k) }
      diff_list_for(left_differences, :remove)
    end

    def right_join_differences
      right_differences = destination_metadata_after_transforms.keep_if { |k, _v| !source_metadata_after_transforms.key?(k) }
      diff_list_for(right_differences, :add)
    end

    def common_fields_differences
      common_differences = destination_metadata_after_transforms.keep_if do |k, v|
        if source_metadata_after_transforms[k].present?
          begin
            Array.wrap(JSON.parse(source_metadata_after_transforms[k][0])).to_set != Array.wrap(JSON.parse(v[0])).to_set
          rescue
            source_metadata_after_transforms[k].present? && Array.wrap(source_metadata_after_transforms[k]).to_set != Array.wrap(v).to_set
          end
        end
      end
      diff_list_for(common_differences, :change)
    end

    protected

      def valid_endpoint_params?
        @source_base_url && @source_username && @source_password && @destination_base_url && @destination_username && @destination_password
      end

      def diff_list_for(issues, operation)
        issues.map { |k, v| { path: k, op: operation, value: v } }
      end

      def filter_out_excluded_fields(metadata)
        metadata.select { |k, _v| !EXCLUDED_FIELDS.include?(k.to_sym) }
      end

      def rename_fields(metadata)
        RENAMED_FIELDS.each do |k, v|
          metadata[v] = metadata.delete(k)
        end
        metadata
      end

      def reevaluate_fields(metadata)
        metadata.clone.each do |k, v|
          reeval_method_name = "reevaluate_#{k}"
          next unless methods.include?(reeval_method_name.to_sym) && v.try(:any?)

          new_value = send(reeval_method_name, v)
          Rails.logger.info "Reeval #{k}\n\t#{v}\n\t#{new_value}"
          metadata[k] = new_value
        end
        metadata
      end

      COMMON_CONTRIBUTOR_AND_CREATOR_FIELDS = %w[
        organization_name given_name middle_name family_name name_type orcid isni ror grid wikidata suffix institution
      ].freeze

      def reevaluate_creator_tesim(old_value)
        returning_value = []
        old_value.each do |creator_tesim|
          creator_tesim = JSON.parse(creator_tesim)[0]
          COMMON_CONTRIBUTOR_AND_CREATOR_FIELDS.each do |field|
            creator_tesim["creator_#{field}"] ||= ""
          end
          creator_tesim["creator_role"] = Array.wrap(creator_tesim["creator_role"])
          creator_tesim["creator_institutional_relationship"] = Array.wrap(creator_tesim["creator_institutional_relationship"])
          creator_tesim["creator_suffix"] ||= ""
          creator_tesim["creator_position"] ||= "0"
          returning_value.push([creator_tesim].to_json)
        end
        returning_value
      end

      def reevaluate_contributor_tesim(old_value)
        returning_value = []
        old_value.each do |contributor_tesim|
          contributor_tesim = JSON.parse(contributor_tesim)[0]
          COMMON_CONTRIBUTOR_AND_CREATOR_FIELDS.each do |field|
            contributor_tesim["contributor_#{field}"] ||= ""
          end
          contributor_tesim["contributor_position"] ||= "0"
          contributor_tesim["contributor_institutional_relationship"] = Array.wrap(contributor_tesim["contributor_institutional_relationship"])
          returning_value.push([contributor_tesim].to_json)
        end
        returning_value
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
        else
          initial_value
        end
      end

      def gross_work_type_name(alt_name)
        alt_name.first.gsub(/Pacific|Work|\s*/, '')
      end
  end
end
