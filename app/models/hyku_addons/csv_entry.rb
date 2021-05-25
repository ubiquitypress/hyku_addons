# frozen_string_literal: true
module HykuAddons
  class CsvEntry < Bulkrax::CsvEntry
    def self.matcher_class
      HykuAddons::CsvMatcher
    end

    # def build_for_importer
    #   begin
    #     build_metadata
    #     unless self.importerexporter.validate_only
    #       raise Bulkrax::CollectionsCreatedError unless collections_created?
    #       @item = factory.run!
    #     end
    #   rescue RSolr::Error::Http, Bulkrax::CollectionsCreatedError => e
    #     raise e
    #   rescue StandardError => e
    #     status_info(e)
    #   else
    #     status_info
    #   end
    #   return @item
    # end

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
      add_resource_type

      parsed_metadata
    end

    # Override to use the value in prefer the named admin set provided in the admin_set column then fallback to previous behavior
    def add_admin_set_id
      parsed_metadata['admin_set_id'] = nil if parsed_metadata['admin_set_id'].blank?
      parsed_metadata['admin_set_id'] ||= AdminSet.find_by(title: raw_metadata['admin_set'])&.id || AdminSet.find_by(id: raw_metadata['admin_set'])&.id || importerexporter.admin_set_id
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

    # Override to allow `id` as system identifier field
    def valid_system_id(model_class)
      return true if Bulkrax.system_identifier_field == 'id'
      return true if model_class.properties.keys.include?(Bulkrax.system_identifier_field)
      raise("#{model_class} does not implement the system_identifier_field: #{Bulkrax.system_identifier_field}")
    end

    def collections_created?
      super && admin_set_created?
    end

    def admin_set_created?
      return true if record["admin_set"].blank?
      admin_set = AdminSet.find_by(title: record["admin_set"]) || AdminSet.where(id: record["admin_set"])
      admin_set.present?
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
      # self.parsed_metadata['id'] = hyrax_record.id
      parsed_metadata[self.class.source_identifier_field] = hyrax_record.id
      parsed_metadata['model'] = hyrax_record.has_model.first
      build_mapping_metadata
      unless hyrax_record.is_a?(Collection)
        parsed_metadata['file'] = hyrax_record.file_sets.map { |fs| filename(fs)&.to_s.presence }.compact.join('|')
      end
      build_json_metadata
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
        JSON.parse(json_str).each_with_index { |h, i| h.each { |k, v| parsed_metadata["#{k}_#{i + 1}"] = v } }
      rescue JSON::ParseError
        next
      end
    end

    def export_mapping
      # Add all fields from this model to the mapping unless explicitly excluded by already being in the mapping
      map = mapping.reject { |k, _| k == 'model' || (Bulkrax.reserved_properties.include?(k) && !field_supported?(k)) }
      hyrax_record.attributes.keys.map { |k| map[k] = { 'from' => [k] } unless map.key?(k) || Bulkrax.reserved_properties.include?(k) || !field_supported?(k) }
      map
    end
  end
end
