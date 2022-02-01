# frozen_string_literal: true

module HykuAddons
  module ImporterOverrides
    # Override to add date and json field handling
    def build_metadata
      raise StandardError, "Record not found" if record.nil?
      raise StandardError, "Missing required elements, required elements are: #{importerexporter.parser.required_elements.join(', ')}" unless importerexporter.parser.required_elements?(record.keys)

      create_metadata
      transform_metadata

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
          file_metadata[file_index]["file"] = v
        end
      end

      parsed_metadata["file"] = file_metadata.pluck("file") if parsed_metadata["file"].blank?
      parsed_metadata["file"] = parsed_metadata["file"].map { |f| path_to_file(f) }
      parsed_metadata["file_set"] = file_metadata
    end

    # Override to use the value in prefer the named admin set provided in the admin_set column then fallback to previous behavior
    def add_admin_set_id
      parsed_metadata["admin_set_id"] = nil if parsed_metadata["admin_set_id"].blank?
      parsed_metadata["admin_set_id"] ||= AdminSet.where(title: raw_metadata["admin_set"]).first&.id ||
                                          AdminSet.where(id: raw_metadata["admin_set"]).first&.id ||
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

    # This method ensures that existing records can only have their doi_status changed
    # to valid statuses.  Since there is no status for do_not_mint, it adds nil to the list
    # of DataCiteRegistrar::STATES then calculates the index in this list for the
    # current and new status.  If the status has moved forwards it updates, otherwise we
    # revert to the original status.
    # In order to do this we need to fetch the current_doi_status from the factory.
    # WARNING: we cannot call find on the factory in this class.  Doing so prevents the work from being
    # updated because the factory will be initialized with the metadata in the current state
    # before this code has updated it
    def add_doi_status_field
      return unless parsed_metadata["doi_status_when_public"] && current_doi_status

      doi_statuses = [nil] + Hyrax::DOI::DataCiteRegistrar::STATES
      current_doi_status_id = doi_statuses.index(current_doi_status) || 0
      new_doi_status_id = doi_statuses.index(record["doi_status_when_public"]) || 0

      parsed_metadata["doi_status_when_public"] = current_doi_status if new_doi_status_id < current_doi_status_id
    end

    def add_json_fields
      delimiter = %r{\|}

      # NOTE: When the schema migration is complete, this can be replaced with:
      # json_fields = factory_class.json_fields.keys
      json_fields = factory_class.new.schema_driven? ? factory_class.json_fields.keys : factory_class.json_fields

      json_fields.map(&:to_s).each do |field|
        field_json = []

        raw_metadata.select { |key, _v| key.starts_with? field.to_s }.each do |key, value|
          match = key.match(/^(?<subfield>.+)_(?<index>\d+)$/)

          # If the value is defined as multiple by including a `|`, split and set as an array
          value = value.split(delimiter) if value.match?(delimiter)

          (field_json[match[:index].to_i - 1] ||= {})[match[:subfield]] = value
        end

        parsed_metadata[field] = field_json
      end
    end

    def add_controlled_vocabulary_field(field, service_class)
      return unless parsed_metadata[field].present?

      service = service_class.new(model: parsed_metadata["model"]&.safe_constantize)
      parsed_metadata[field] = parsed_metadata[field].map do |val|
        service.authority.find(val).fetch("id")
      rescue
        nil
      end.compact
    end

    # Removes the replcement of spaces to underscores https://github.com/samvera-labs/bulkrax/blob/master/app/models/bulkrax/csv_entry.rb#L84
    def add_file
      parsed_metadata["file"] ||= []

      if record["file"]&.is_a?(String)
        parsed_metadata["file"] = record["file"].split(/\s*[;|]\s*/)
      elsif record["file"].is_a?(Array)
        parsed_metadata["file"] = record["file"]
      end

      parsed_metadata["file"] = parsed_metadata["file"].map { |f| path_to_file(f) }
    end

    # If only filename is given, construct the path (/files/my_file)
    def path_to_file(file)
      # return if we already have the full file path
      return file if File.exist?(file)

      path = ENV["BULKRAX_FILE_PATH"]
      path ||= importerexporter.parser.path_to_files
      f = File.join(path, file)

      return f if File.exist?(f)

      raise "File #{f} does not exist."
    end

    private

      def create_metadata
        self.parsed_metadata = {}
        parsed_metadata[Bulkrax.system_identifier_field] = record["source_identifier"]
        parsed_metadata["id"] = record["id"] if record["id"].present?

        record.each do |key, value|
          next if key == "collection"

          add_metadata(key, value)
        end
      end

      def transform_metadata
        add_file
        add_file_subfields
        add_visibility
        add_rights_statement
        add_admin_set_id
        add_collections
        add_local
        add_date_fields
        add_json_fields
        add_doi_status_field
        add_controlled_vocabulary_field("resource_type", HykuAddons::ResourceTypesService)
        add_controlled_vocabulary_field("subject", HykuAddons::SubjectService)
        add_controlled_vocabulary_field("language", HykuAddons::LanguageService)
      end
  end
end
