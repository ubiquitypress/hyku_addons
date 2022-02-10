# frozen_string_literal: true

module CsvWriterHelper
  # --- CSV Methods ---

  # Write a csv of faked data by reading the schema configuration for the model
  # Some fields must be given special values for the importer to work
  # source_identifier must be unique
  # model name must be set for the work type we are importing
  # depositor's email must exist
  # Bulkrax cannot import multiple titles or urls for one work, even though they are a multiple field
  def create_csv
    delete_csv_file

    file = File.new(temporary_file_path, "wb")

    CSV.open(file, "wb", headers: headers, write_headers: true) do |row|
      number_of_records.times.each do |i|
        hardcoded_fields = ["id-#{i}", "source-#{i}", model_name, depositor.email, "Test Title #{i}", "https://fake.url.com/"]
        row << hardcoded_fields + fake_row_data(i)
      end
    end

    file.close
  end

  def delete_csv_file
    File.delete(temporary_file_path) if File.exist?(temporary_file_path)
  end

  def temporary_file_path
    "spec/fixtures/csv/#{model_name.underscore}_dynamic_data.csv"
  end

  # Subfields should be merged with regular fields as the importer treats them like any other column header
  def headers
    subfields_with_suffixes = subfields.transform_keys { |k| "#{k}_1".to_sym }
    hardcoded_fields = %w[id source_identifier model depositor title related_url]
    hardcoded_fields + field_configs_without_subfields.merge!(subfields_with_suffixes).keys
  end

  # --- Schema methods ---

  def field_configs
    "Hyrax::#{model_name}Form".constantize.field_configs.reject { |k, _v| untested_attributes.include?(k) }
  end

  def excluded_fields
    Bulkrax.field_mappings["HykuAddons::CsvParser"].map { |k, v| k.to_sym if v.dig(:excluded) }.compact || []
  end

  def field_configs_without_subfields
    field_configs.reject { |_k, v| v.key?(:subfields) }
  end

  def subfields
    field_configs.map { |_k, v| v.dig(:subfields) }
                 .compact
                 .reduce({}, :merge)
                 .reject { |k, _v| untested_attributes.include?(k) }
  end

  def attributes
    field_configs_without_subfields.merge!(subfields)
  end

  def untested_attributes
    excluded_fields + %i[relation_type subject resource_type title related_url]
  end

  # --- Data Generators ---

  def fake_row_data(i)
    attributes.collect { |attribute| faked_attribute(attribute.first, i) }
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def faked_attribute(name, i)
    return unless name.is_a? Symbol

    if attributes[name][:type] == "date"
      time_field
    elsif attributes[name][:type] == "select" && attributes.dig(name, :authority)
      authority_field(name)
    elsif attributes[name][:type] == "textarea"
      "A long piece of text." * 20
    elsif attributes[name][:multiple]
      multiple_field(name, i)
    else
      "#{name}-#{i}"
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  # Here we do not use the Bulkrax delimiter, which is escaped
  # We use the unescaped delimiter as a customer would when entering data

  # rubocop:disable Performance/TimesMap
  def multiple_field(name, i)
    (i + 1).times.map { |n| "#{name}-#{n}" }.join(csv_delimiter)
  end
  # rubocop:enable Performance/TimesMap

  # Get a random valid option for an authority, and select the value (not the key)
  def authority_field(name)
    attributes[name][:authority]
      .constantize
      .new(model: model_name.constantize)
      .select_active_options
      .sample
      &.second
  end

  # Dates can be in full, or just years or months within a year
  def time_field
    t = Time.zone.at(rand * Time.current.to_i)
    [t.strftime("%Y-%m-%d"), t.strftime("%Y-%m"), t.strftime("%Y")].sample
  end
end
