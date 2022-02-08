# frozen_string_literal: true

module HykuAddons
  class CsvEntry < Bulkrax::CsvEntry
    include ExporterOverrides
    include ImporterOverrides

    def self.matcher_class
      HykuAddons::CsvMatcher
    end

    # Override to allow `id` as system identifier field
    def valid_system_id(model_class)
      return true if Bulkrax.system_identifier_field == "id"
      # Collection and AdminSet are handled differently so don't worry about them
      return true if model_class == Collection || model_class == AdminSet
      return true if model_class.properties.keys.include?(Bulkrax.system_identifier_field)
      raise("#{model_class} does not implement the system_identifier_field: #{Bulkrax.system_identifier_field}")
    end

    def find_collection(collection_identifier)
      Collection.where(id: collection_identifier).first
    end

    def collections_created?
      super && admin_set_created?
    end

    def admin_set_created?
      return true if record["admin_set"].blank?
      AdminSet.where(title: record["admin_set"]).any? || AdminSet.where(id: record["admin_set"]).any?
    end

    def hyrax_record
      begin
        super
      rescue
        nil
      end || factory.find
    end

    private

      def current_doi_status
        query = { Bulkrax.system_identifier_field => record["source_identifier"] }
        match = factory_class.where(query).detect { |m| m.send(Bulkrax.system_identifier_field).include?(record["source_identifier"]) }

        match&.doi_status_when_public
      end
  end
end
