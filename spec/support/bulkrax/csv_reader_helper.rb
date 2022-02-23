# frozen_string_literal: true

module CsvReaderHelper
  # Read a row from a CSV file and make expectations for each column
  # Subfields (like creator_given_name) will be a column like any other and so these must be handled separately
  # rubocop:disable Metrics/MethodLength
  def csv_row_to_expectations(row, work)
    expectations = []

    field_configs.each do |attribute|
      attribute_name = attribute.first.to_s
      attribute_properties = attribute.last

      if work.respond_to?(attribute_name)
        if attribute_properties.dig(:subfields)
          attribute_properties[:subfields].keys.reject { |k| untested_attributes.include?(k) }.each do |subfield|
            expectations << get_expectations_for_subfield(attribute_name, subfield, attribute_properties[:multiple], row, work)
          end
        else
          # TODO: Bulkrax sets rights_statement as a multiple field, but it is not
          wrongly_configured_fields = ["rights_statement"]
          attribute_multiple = attribute_properties[:multiple] || wrongly_configured_fields.include?(attribute_name)
          expectations << get_expectations_for_field(attribute_name, attribute_multiple, row, work)
        end
      end
    end

    expectations
  end
  # rubocop:enable Metrics/MethodLength

  # Parse the CSV data for comparison with the model
  # If the field is multiple it will be saved in the model as an array: ["value"]
  def get_expectations_for_field(attribute_name, attribute_multiple, row, work)
    attribute_test_value = attribute_multiple ? row[attribute_name].split(csv_delimiter) : row[attribute_name]
    attribute_actual_value = work.send(attribute_name)

    { attribute_name: attribute_name, actual: attribute_actual_value, test: attribute_test_value }
  end

  # Parse the CSV data for subfields for comparison with the model
  # If a subfield is multiple it will only be saved in the model as an array if it has more than one value
  def get_expectations_for_subfield(attribute_name, subfield, attribute_multiple, row, work)
    split_data = row["#{subfield}_1"].split(csv_delimiter)
    attribute_test_value = attribute_multiple && split_data.count > 1 ? split_data : row["#{subfield}_1"]
    attribute_actual_value = JSON.parse(work.send(attribute_name).first, symbolize_names: true).first[subfield]

    { attribute_name: subfield, actual: attribute_actual_value, test: attribute_test_value }
  end

  # We need to use an unescaped delimiter instead of using Bulkrax's field_mappings to read and write from the CSV file
  # Customers do not add escaping to the delimiters
  def csv_delimiter
    "|"
  end
end
