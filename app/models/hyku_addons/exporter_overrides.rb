# frozen_string_literal: true

module HykuAddons
  module ExporterOverrides
    def build_export_metadata
      # Skip #make_round_trippable because it attempts to modify the original hyrax record
      # which we don't need because we use the id of the hyrax record as the source_identifier
      # make_round_trippable
      self.parsed_metadata = {}
      # We don't need a separate column for id because it is already in the source_identifer_field
      parsed_metadata["id"] = hyrax_record.id
      parsed_metadata["model"] = hyrax_record.has_model.first
      build_mapping_metadata
      build_file_visibility
      build_json_metadata
      # Populate source_identifer if it doesn't have a value similar to make_round_trippable
      parsed_metadata[self.class.source_identifier_field] ||= hyrax_record.id
      parsed_metadata["visibility"] = hyrax_record.visibility
      parsed_metadata["admin_set"] = hyrax_record.admin_set_id
      parsed_metadata["collection"] = hyrax_record.member_of_collection_ids.join("|")
      parsed_metadata
    end

    def build_mapping_metadata
      export_mapping.each do |key, value|
        method_name = Array.wrap(value["from"]).first || key
        data = hyrax_data(method_name&.to_s)
        parsed_metadata[key] = transform_relations(data) unless value[:excluded] && data.is_a?(ActiveTriples::Relation)
      end
    end

    def build_json_metadata
      json_fields.each do |field|
        json_str = parsed_metadata.delete(field)

        split_json(json_str) if json_str.present?
      end
    end

    def build_file_visibility
      hyrax_files_sets.each_with_index do |fs, i|
        index = i + 1
        parsed_metadata["file_#{index}"] = filename(fs).to_s.presence
        parsed_metadata["file_visibility_#{index}"] = fs.visibility

        add_embargo_details(fs, index)
      end
    end

    def export_mapping
      # Add all fields from this model to the mapping unless explicitly excluded by already being in the mapping
      map = mapping.select { |k, _| k != "model" && supported_and_unreserved_field(k) }
      hyrax_record.attributes.keys.map { |k| map[k] ||= { "from" => Array.wrap(k) } if supported_and_unreserved_field(k) }
      map
    end

    private

    def supported_and_unreserved_field(k)
      field_supported?(k) && ::Bulkrax.reserved_properties.exclude?(k)
    end

    def add_embargo_details(fs, index)
      return unless fs.embargo

      parsed_metadata["file_visibility_#{index}"] = "embargo"
      parsed_metadata["file_visibility_during_embargo_#{index}"] = fs.visibility_during_embargo
      parsed_metadata["file_visibility_after_embargo_#{index}"] = fs.visibility_after_embargo
      parsed_metadata["file_embargo_release_date_#{index}"] = fs.embargo_release_date&.to_date&.to_s
    end

    def hyrax_data(method_name)
      return unless hyrax_record.respond_to?(method_name)

      hyrax_record.send(method_name)
    end

    def transform_relations(data)
      if data.is_a?(ActiveTriples::Relation)
        data.map { |d| prepare_export_data(d) }.join("|").to_s
      else
        prepare_export_data(data)
      end
    end

    def json_fields
      json_fields = hyrax_record.class.json_fields

      # NOTE: Once the schema migration has been completed, this should be the default
      json_fields = json_fields.keys if hyrax_record.schema_driven?

      json_fields.map(&:to_s)
    end

    def split_json(str)
      # Split JSON into separate columns for each subfield suffixed by index within the JSON (e.g. creator_given_name_1)
      parsed_json = begin
                      JSON.parse(str)
                    rescue JSON::ParseError
                      nil
                    end

      parsed_json.each_with_index do |h, i|
        h.each { |k, v| parsed_metadata["#{k}_#{i + 1}"] = v }
      end
    end

    def hyrax_files_sets
      return if hyrax_record.is_a?(Collection)

      file_sets = hyrax_record.ordered_members.to_a
      file_sets.select { |fs| fs.is_a?(FileSet) && filename(fs).present? }
    end
  end
end
