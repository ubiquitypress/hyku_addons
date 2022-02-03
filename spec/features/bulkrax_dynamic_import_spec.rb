# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe "Bulkrax import", clean: true, slow: true do
  let(:model_name) { "UbiquityTemplateWork" }
  let(:number_of_records) { 2 }

  let(:user) { create(:user, email: "test@example.com") }
  let!(:depositor) { build_stubbed(:user, email: "batchuser@example.com") }
  let(:temporary_file_path) { "spec/fixtures/csv/dynamic_data.csv" }

  let(:importer) do
    create(:bulkrax_importer_csv,
           user: user,
           field_mapping: Bulkrax.field_mappings["HykuAddons::CsvParser"],
           parser_klass: "HykuAddons::CsvParser",
           parser_fields: { "import_file_path" => temporary_file_path },
           limit: 0)
  end

  before do
    # Make sure default admin set exists
    AdminSet.find_or_create_default_admin_set_id
    stub_request(:get, Addressable::Template.new("#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/translate?uri=urn:uuid:{id}")).to_return(status: 200)
    allow(Hyrax::Hirmeos::HirmeosFileUpdaterJob).to receive(:perform_later)

    create_csv

    perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
      importer.import_collections
    end
  end

  after do
    delete_csv_file
  end

  it "imports works" do
    expect do
      perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
        importer.import_works
      end
    end.to change { model_name.constantize.count }.by(number_of_records)

    aggregate_failures do
      CSV.read(temporary_file_path, headers: true).each do |row|
        work = model_name.constantize.where(source_identifier: row["source_identifier"]).first
        expectations = csv_row_to_expectations(row, work)

        expectations.each do |expectation|
          expect(expectation[:actual]).to eq(expectation[:test]), "expected #{expectation[:attribute_name]} to equal #{expectation[:test]} but got #{expectation[:actual]}"
        end
      end
    end
  end

  private

    # Schema methods

    def field_configs
      Hyrax::UbiquityTemplateWorkForm.field_configs.reject { |k, _v| untested_attributes.include?(k) }
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
      %i[resource_type language rights_statement relation_type subject display_creator_profile]
    end

    # CSV Methods

    def headers
      subfields_with_suffixes = subfields.transform_keys { |k| "#{k}_1".to_sym }
      %w[id source_identifier model depositor] + field_configs_without_subfields.merge!(subfields_with_suffixes).keys
    end

    def create_csv
      delete_csv_file
      file = File.new(temporary_file_path, "wb")

      CSV.open(file, "wb", headers: headers, write_headers: true) do |row|
        number_of_records.times.each do |i|
          row << ["id-#{i}", "source-#{i}", model_name, depositor.email] + faked_data(i)
        end
      end

      file.close
    end

    def delete_csv_file
      File.delete(temporary_file_path) if File.exist?(temporary_file_path)
    end

    def faked_data(i)
      attributes.collect { |attribute| faked_attribute(attribute.first, i) }
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/AbcSize
    def faked_attribute(name, i)
      return unless name.is_a? Symbol

      if name == :creator_name_type_1
        "Personal"
      elsif attributes[name][:type] == "date"
        Time.zone.at(rand * Time.current.to_i).strftime("%Y-%m-%d")
      elsif attributes[name][:type] == "select" && attributes.dig(name, :authority)
        attributes[name][:authority].constantize.new(model: model_name.constantize).select_active_options.sample&.first
      elsif attributes[name][:type] == "textarea"
        "A long piece of text. A long piece of text. A long piece of text. A long piece of text. A long piece of text. A long piece of text. A long piece of text. A long piece of text."
      else
        "#{name}-#{i}"
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize

    # Test methods

    def csv_row_to_expectations(row, work)
      expectations = []

      field_configs.each do |attribute|
        attribute_name = attribute.first.to_s
        attribute_properties = attribute.last

        if work.respond_to?(attribute_name)
          if attribute_properties.dig(:subfields)
            # For creator etc, loop through each creator field separately
            attribute_properties[:subfields].reject { |k, _v| untested_attributes.include?(k) }.each_key do |subfield|
              expectations << get_expectations_for_subfield(attribute_name, subfield, row, work)
            end
          else
            expectations << get_expectations_for_field(attribute_name, attribute_properties, row, work)
          end
        end
      end

      expectations
    end

    def get_expectations_for_field(attribute_name, attribute_properties, row, work)
      attribute_test_value = attribute_properties[:multiple] ? [row[attribute_name]] : row[attribute_name]
      attribute_actual_value = work.send(attribute_name)

      { attribute_name: attribute_name, actual: attribute_actual_value, test: attribute_test_value }
    end

    def get_expectations_for_subfield(attribute_name, subfield, row, work)
      attribute_test_value = row["#{subfield}_1"]
      attribute_actual_value = JSON.parse(work.send(attribute_name).first, symbolize_names: true).first[subfield]

      { attribute_name: subfield, actual: attribute_actual_value, test: attribute_test_value }
    end
end
