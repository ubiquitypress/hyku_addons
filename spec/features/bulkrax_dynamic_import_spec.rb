# frozen_string_literal: true

require "rails_helper"
require "csv"

# rubocop:disable RSpec/InstanceVariable
RSpec.describe "Bulkrax import", clean: true, slow: true do
  let(:user) { create(:user, email: "test@example.com") }
  let!(:depositor) { build_stubbed(:user, email: "batchuser@example.com") }

  let(:number_of_records) { 3 } # Setting this too high will increase the test time for little gain

  after do
    File.delete("spec/fixtures/csv/ubiquity_template_work_dynamic_data.csv") if File.exist?("spec/fixtures/csv/ubiquity_template_work_dynamic_data.csv")
    File.delete("spec/fixtures/csv/uva_work_dynamic_data.csv") if File.exist?("spec/fixtures/csv/uva_work_dynamic_data.csv")
  end

  ["UbiquityTemplateWork", "UvaWork"].each do |model_name|
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

      # We cannot use let to memoize model name because Rspec will not reset it when we iterate
      @model_name = model_name
      create_csv
    end

    it "imports #{model_name} works" do
      expect do
        perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
          importer.import_collections
        end

        perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
          importer.import_works
        end
      end.to change { @model_name.constantize.count }.by(number_of_records)

      aggregate_failures do
        CSV.read(temporary_file_path, headers: true).each do |row|
          work = @model_name.constantize.where(source_identifier: row["source_identifier"]).first
          expectations = csv_row_to_expectations(row, work)

          expectations.each do |expectation|
            expect(expectation[:actual]).to eq(expectation[:test]), "expected #{expectation[:attribute_name]} to equal #{expectation[:test]} but got #{expectation[:actual]}"
          end
        end
      end
    end
  end

  private

    # Schema methods

    def field_configs
      "Hyrax::#{@model_name}Form".constantize.field_configs.reject { |k, _v| untested_attributes.include?(k) }
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
      %i[relation_type subject display_creator_profile resource_type title related_url]
    end

    # CSV Methods

    def headers
      subfields_with_suffixes = subfields.transform_keys { |k| "#{k}_1".to_sym }
      %w[id source_identifier model depositor title related_url] + field_configs_without_subfields.merge!(subfields_with_suffixes).keys
    end

    def create_csv
      delete_csv_file

      file = File.new(temporary_file_path, "wb")

      CSV.open(file, "wb", headers: headers, write_headers: true) do |row|
        number_of_records.times.each do |i|
          row << ["id-#{i}", "source-#{i}", @model_name, depositor.email, "Test Title #{i}", "https://fake.url.com/"] + fake_row_data(i)
        end
      end

      file.close
    end

    def delete_csv_file
      File.delete(temporary_file_path) if File.exist?(temporary_file_path)
    end

    def temporary_file_path
      "spec/fixtures/csv/#{@model_name.underscore}_dynamic_data.csv"
    end

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
        select_field(name)
      elsif attributes[name][:type] == "textarea"
        "A long piece of text. A long piece of text. A long piece of text. A long piece of text. A long piece of text."
      elsif attributes[name][:multiple]
        multiple_field(name, i)
      else
        "#{name}-#{i}"
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    # rubocop:disable Performance/TimesMap
    def multiple_field(name, i)
      (i + 1).times.map { |n| "#{name}-#{n}" }.join("|")
    end
    # rubocop:enable Performance/TimesMap

    def select_field(name)
      attributes[name][:authority].constantize.new(model: @model_name.constantize).select_active_options.sample&.second
    end

    def time_field
      t = Time.zone.at(rand * Time.current.to_i)
      [t.strftime("%Y-%m-%d"), t.strftime("%Y-%m"), t.strftime("%Y")].sample
    end

    # Test methods

    def csv_row_to_expectations(row, work)
      expectations = []

      field_configs.each do |attribute|
        attribute_name = attribute.first.to_s
        attribute_properties = attribute.last

        if work.respond_to?(attribute_name)
          if attribute_properties.dig(:subfields)
            # For creator etc, loop through each creator field separately
            attribute_properties[:subfields].keys.reject { |k| untested_attributes.include?(k) }.each do |subfield|
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
      # TODO: Bulkrax sets rights_statement as a multiple field, but it is not

      attribute_test_value = attribute_properties[:multiple] || attribute_name == "rights_statement" ? row[attribute_name].split("|") : row[attribute_name]
      attribute_actual_value = work.send(attribute_name)

      { attribute_name: attribute_name, actual: attribute_actual_value, test: attribute_test_value }
    end

    def get_expectations_for_subfield(attribute_name, subfield, row, work)
      attribute_test_value = row["#{subfield}_1"]
      attribute_actual_value = JSON.parse(work.send(attribute_name).first, symbolize_names: true).first[subfield]

      { attribute_name: subfield, actual: attribute_actual_value, test: attribute_test_value }
    end
end
# rubocop:enable RSpec/InstanceVariable
