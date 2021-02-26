# frozen_string_literal: true
module HykuAddons
  class CsvEntry < Bulkrax::CsvEntry
    def self.matcher_class
      HykuAddons::CsvMatcher
    end

    # Override to add date and json field handling
    def build_metadata
      raise StandardError, 'Record not found' if record.nil?

      raise StandardError, "Missing required elements, required elements are: #{importerexporter.parser.required_elements.join(', ')}" unless importerexporter.parser.required_elements?(record.keys)

      self.parsed_metadata = {}
      parsed_metadata[Bulkrax.system_identifier_field] = record['source_identifier']

      record.each do |key, value|
        next if key == 'collection'
        add_metadata(key, value)
      end

      add_file
      add_visibility
      add_rights_statement
      add_admin_set_id
      add_collections
      add_local
      add_date_fields
      add_json_fields

      parsed_metadata
    end

    # Override to use the value in prefer the named admin set provided in the admin_set column then fallback to previous behavior
    def add_admin_set_id
      parsed_metadata['admin_set_id'] = AdminSet.where(title: raw_metadata['admin_set']).first&.id if parsed_metadata['admin_set_id'].blank?
      parsed_metadata['admin_set_id'] = importerexporter.admin_set_id if parsed_metadata['admin_set_id'].blank?
    end

    # TODO: memoize factory class to avoid having to compute it each time
    def add_date_fields
      factory_class.date_fields.map(&:to_s).each do |field|
        next unless mapping[field] && record[field.to_s].present?
        matcher = self.class.matcher(field, mapping[field].symbolize_keys)
        result = matcher.result(self, record[field.to_s])
        parsed_metadata[field] = Array.wrap(result)
      end
    end

    def add_json_fields
      factory_class.json_fields.map(&:to_s).each do |field|
        field_json = []
        raw_metadata.select { |k, _v| k.starts_with? field.to_s }.each do |k, v|
          match = k.match(/^(?<subfield>.+)_(?<index>\d+)$/)
          field_json[match[:index].to_i - 1] ||= {}
          field_json[match[:index].to_i - 1][match[:subfield]] = v
        end
        parsed_metadata[field] = field_json
      end
    end

    # Override to allow `id` as system identifier field
    def valid_system_id(model_class)
      return true if Bulkrax.system_identifier_field == 'id'
      return true if model_class.properties.keys.include?(Bulkrax.system_identifier_field)
      raise("#{model_class} does not implement the system_identifier_field: #{Bulkrax.system_identifier_field}")
    end
  end
end
