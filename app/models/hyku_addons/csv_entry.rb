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
      parsed_metadata['id'] = record['id'] if record['id'].present?

      record.each do |key, value|
        next if key == 'collection'
        add_metadata(key, value)
      end

      add_file
      add_file_subfields
      add_visibility
      add_rights_statement
      add_admin_set_id
      add_collections
      add_local
      add_date_fields
      add_json_fields
      add_resource_type
      add_subject

      parsed_metadata
    end

    def add_file_subfields
      file_metadata = []
      raw_metadata.select { |k, _v| k =~ /^file_((?<subfield>.+)_)?(?<index>\d+)$/ }.each do |k, v|
        match = k.match(/^file_((?<subfield>.+)_)?(?<index>\d+)$/)
        file_index = match[:index].to_i - 1
        file_metadata[file_index] ||= {}
        if (subfield = match[:subfield].presence)
          file_metadata[file_index][subfield] = v
        else
          file_metadata[file_index]['file'] = v
        end
      end
      parsed_metadata['file'] = file_metadata.pluck('file') if parsed_metadata['file'].blank?
      parsed_metadata['file'] = parsed_metadata['file'].map { |f| path_to_file(f.tr(' ', '_')) }
      parsed_metadata['file_set'] = file_metadata
    end

    # Override to use the value in prefer the named admin set provided in the admin_set column then fallback to previous behavior
    def add_admin_set_id
      parsed_metadata['admin_set_id'] = nil if parsed_metadata['admin_set_id'].blank?
      parsed_metadata['admin_set_id'] ||= AdminSet.where(title: raw_metadata['admin_set']).first&.id ||
                                          AdminSet.where(id: raw_metadata['admin_set']).first&.id ||
                                          importerexporter.admin_set_id
    end

    # TODO: memoize factory class to avoid having to compute it each time
    # Do this because add_metadata gets it wrong and this does it right
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

    def add_resource_type
      resource_type_service = HykuAddons::ResourceTypesService.new(model: parsed_metadata['model']&.safe_constantize)
      parsed_metadata['resource_type'] = parsed_metadata['resource_type'].map do |resource_type|
        resource_type_service.label(resource_type.strip.titleize)
      rescue
        nil
      end.compact
    end

    def add_subject
      return unless parsed_metadata['subject'].present?
      subject_service = HykuAddons::SubjectService.new(model: parsed_metadata['model']&.safe_constantize)
      parsed_metadata['subject'] = parsed_metadata['subject'].map do |subject|
        subject_service.label(subject.strip)
      rescue
        nil
      end.compact
    end

    # Override to allow `id` as system identifier field
    def valid_system_id(model_class)
      return true if Bulkrax.system_identifier_field == 'id'
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

    # If only filename is given, construct the path (/files/my_file)
    def path_to_file(file)
      # return if we already have the full file path
      return file if File.exist?(file)
      path = ENV['BULKRAX_FILE_PATH']
      path ||= importerexporter.parser.path_to_files
      f = File.join(path, file)
      return f if File.exist?(f)
      raise "File #{f} does not exist"
    end

    ### Exporter overrides
    def build_export_metadata
      # Skip #make_round_trippable because it attempts to modify the original hyrax record
      # which we don't need because we use the id of the hyrax record as the source_identifier
      # make_round_trippable
      self.parsed_metadata = {}
      # We don't need a separate column for id because it is already in the source_identifer_field
      parsed_metadata['id'] = hyrax_record.id
      parsed_metadata['model'] = hyrax_record.has_model.first
      build_mapping_metadata
      unless hyrax_record.is_a?(Collection)
        parsed_metadata['file'] = hyrax_record.file_sets
                                              .map { |fs| filename(fs)&.to_s.presence }
                                              .compact
                                              .join('|')
      end
      build_json_metadata
      # Populate source_identifer if it doesn't have a value similar to make_round_trippable
      parsed_metadata[self.class.source_identifier_field] ||= hyrax_record.id
      parsed_metadata['visibility'] = hyrax_record.visibility
      parsed_metadata['admin_set'] = hyrax_record.admin_set_id
      parsed_metadata['collection'] = hyrax_record.member_of_collection_ids.join('|')
      parsed_metadata
    end

    def build_mapping_metadata
      export_mapping.each do |key, value|
        method_name = Array.wrap(value['from']).first&.to_s || key.to_s
        next unless hyrax_record.respond_to?(method_name)
        data = hyrax_record.send(method_name)
        if data.is_a?(ActiveTriples::Relation)
          parsed_metadata[key] = data.map { |d| prepare_export_data(d) }.join('|').to_s unless value[:excluded]
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

    def export_mapping
      # Add all fields from this model to the mapping unless explicitly excluded by already being in the mapping
      map = mapping.reject { |k, _| k == 'model' || (Bulkrax.reserved_properties.include?(k) && !field_supported?(k)) }
      hyrax_record.attributes.keys.map { |k| map[k] ||= { 'from' => Array.wrap(k) } unless Bulkrax.reserved_properties.include?(k) || !field_supported?(k) }
      map
    end
  end
end
