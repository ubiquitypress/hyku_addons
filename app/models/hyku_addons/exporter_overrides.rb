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
      build_file_visibility unless hyrax_record.is_a?(Collection)
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
        method_name = Array.wrap(value["from"]).first&.to_s || key.to_s
        next unless hyrax_record.respond_to?(method_name)
        data = hyrax_record.send(method_name)
        if data.is_a?(ActiveTriples::Relation)
          parsed_metadata[key] = data.map { |d| prepare_export_data(d) }.join("|").to_s unless value[:excluded]
        else
          parsed_metadata[key] = prepare_export_data(data)
        end
      end
    end

    def build_json_metadata
      hyrax_record.class.json_fields.map(&:to_s).each do |field|
        json_str = parsed_metadata.delete(field)
        next unless json_str.present?
        # Split JSON into separate columns for each subfield suffixed by index within the JSON (e.g. creator_given_name_1)
        JSON.parse(json_str).each_with_index { |h, i| h.each { |k, v| parsed_metadata["#{k}_#{i + 1}"] = v } }
      rescue JSON::ParseError
        next
      end
    end

    def build_file_visibility
      hyrax_record.ordered_members.to_a.each_with_index do |fs, i|
        next unless fs.is_a?(FileSet) && (file = filename(fs)&.to_s.presence)
        index = i + 1
        parsed_metadata["file_#{index}"] = file
        parsed_metadata["file_visibility_#{index}"] = fs.visibility
        next unless fs.embargo

        parsed_metadata["file_visibility_#{index}"] = "embargo"
        parsed_metadata["file_visibility_during_embargo_#{index}"] = fs.visibility_during_embargo
        parsed_metadata["file_visibility_after_embargo_#{index}"] = fs.visibility_after_embargo
        parsed_metadata["file_embargo_release_date_#{index}"] = fs.embargo_release_date&.to_date&.to_s
      end
    end

    def export_mapping
      # Add all fields from this model to the mapping unless explicitly excluded by already being in the mapping
      map = mapping.reject { |k, _| k == "model" || (Bulkrax.reserved_properties.include?(k) && !field_supported?(k)) }
      hyrax_record.attributes.keys.map { |k| map[k] ||= { "from" => Array.wrap(k) } unless Bulkrax.reserved_properties.include?(k) || !field_supported?(k) }
      map
    end
  end
end
