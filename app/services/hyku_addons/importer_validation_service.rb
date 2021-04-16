# frozen_string_literal: true

module HykuAddons
  class ImporterValidationService
    attr_reader :errors, :entry

    def initialize(account, importer, source_service_options = {}, destination_service_options = {})
      @account = account
      @importer = importer
      @source_service_options = source_service_options
      @destination_service_options = destination_service_options

      raise ArgumentError, "You must pass a valid Account" unless @account.present?
      raise ArgumentError, "You must pass a valid HykuAddons::Importer" unless @importer.present?
      raise ArgumentError, "Validation can only be made against successfully imported items" unless @importer.status == "Complete"
      valid_endpoint_params?
    end

    def validate
      @importer.entries.find_each.map do |entry|
        next if entry.is_a?(HykuAddons::CsvAdminSetEntry)

        s = EntryValidationService.new(@account, entry, @source_service_options, @destination_service_options)
        s.validate
        [entry.identifier, s.errors]
      end.compact.to_h
    end

    protected

      def valid_endpoint_params?
        mandatory_keys = %i[base_url username password]
        @source_service_options.assert_valid_keys(mandatory_keys) && @destination_service_options.assert_valid_keys(mandatory_keys)
      end
  end
end
