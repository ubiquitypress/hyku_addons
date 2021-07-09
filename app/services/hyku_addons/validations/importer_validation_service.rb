# frozen_string_literal: true

module HykuAddons
  module Validations
    class ImporterValidationService
      attr_reader :errors, :entry

      def initialize(account, importer, klass)
        @account = account
        @importer = importer
        @klass = klass
        raise ArgumentError, "You must pass a valid Account" unless @account.present?
        raise ArgumentError, "You must pass a valid HykuAddons::Importer" unless @importer.present?
        raise ArgumentError, "Validation can only be made against successfully imported items" unless @importer.status == "Complete"
        valid_endpoint_params?
      end

      def validate
        @importer.entries.find_each.map do |entry|
          next unless entry.is_a?(HykuAddons::CsvEntry)

          @klass.constantize.new(@account, entry)
          s.validate
          [entry.identifier, s.errors]
        end.compact.to_h
      end
    end
  end
end
