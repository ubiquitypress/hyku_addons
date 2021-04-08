# frozen_string_literal: true
require 'json-diff'

module HykuAddons
  class EntryValidationService
    attr_reader :errors

    SOURCE_SERVICE_OPTIONS = {
      base_url: ENV['BULKRAX_SOURCE_BASE_URL'],
      username: ENV['BULKRAX_SOURCE_USERNAME'],
      password: ENV['BULKRAX_SOURCE_PASSWORD']
    }
    DESTINATION_SERVICE_OPTIONS = {
      base_url: ENV['BULKRAX_DESTINATION_BASE_URL'],
      username: ENV['BULKRAX_DESTINATION_USERNAME'],
      password: ENV['BULKRAX_DESTINATION_PASSWORD']
    }

    EXCLUDED_FIELDS = %i[_version_ timestamp ]
    RENAMED_FIELDS = {
        old_name: "new_name"
    }

    def initialize(source_service_options = {}, destination_service_options = {})
      @source_base_url = source_service_options[:base_url] || SOURCE_SERVICE_OPTIONS[:base_url]
      @source_username = source_service_options[:username] || SOURCE_SERVICE_OPTIONS[:username]
      @source_password = source_service_options[:password] || SOURCE_SERVICE_OPTIONS[:password]

      @destination_base_url = destination_service_options[:base_url] || DESTINATION_SERVICE_OPTIONS[:base_url]
      @destination_username = destination_service_options[:username] || DESTINATION_SERVICE_OPTIONS[:username]
      @destination_password = destination_service_options[:password] || DESTINATION_SERVICE_OPTIONS[:password]

      unless @source_base_url && @source_username && @source_password && @destination_base_url && @destination_username && @destination_password
        raise ArgumentError.new("Source and destination service params must be present")
      end
    end

    def validate(entry)
      @errors = JsonDiff.diff(mapped_source_metada(entry), destination_metadata(entry))
      errors.empty?
    end

    def mapped_source_metada(entry)
      filtered = filter_out_excluded_fields(source_metadata(entry))
      filtered_and_renamed = rename_fields(filtered)
      transformed = reevaluate_fields(filtered_and_renamed)
      source_metadata(entry)
    end

    def source_metadata(entry)
      HykuAddons::BlacklightWorkJsonService.new(@source_base_url, @source_username, @source_password).fetch(entry)
    end

    def destination_metadata(entry)
      HykuAddons::BlacklightWorkJsonService.new(@destination_base_url, @destination_username, @destination_password).fetch(entry)
    end

    protected

      def filter_out_excluded_fields(metadata)
        metadata.select { |k, v| !EXCLUDED_FIELDS.include?(k.to_sym) }
      end

      def rename_fields(metadata)
        RENAMED_FIELDS.each do |k, v|
          metadata[v] = metadata.delete(k)
        end
      end

      def reevaluate_fields(metadata)
        metadata.clone.each do |k, v|
          reeval_method_name = "reevaluate_#{k}"
          metadata[k] = send(reeval_method_name, v) if respond_to?(reeval_method_name)
        end
      end

      def reevaluate_creator_tesim(old_value)
        returning_value = []
        old_value.each do |creator_tesim|
          creator_tesim["creator_role"] = ""
          creator_tesim["creator_suffix"] = ""
          returning_value.push(creator_tesim)
        end
        returning_value
      end
  end
end

