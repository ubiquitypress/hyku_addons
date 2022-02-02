# frozen_string_literal: true

require "rails_helper"
require "yaml"
require "csv"

RSpec.describe "Bulkrax import", clean: true, slow: true do
  let(:model_name)  { "UbiquityTemplateWork" }
  let!(:attributes) { create_columns }
  let(:required_attributes) { attributes.select { |_k, v| v["form"]["required"] } }

  let(:number_of_records) { 2 }

  let(:user) { create(:user, email: "test@example.com") }
  let!(:depositor) { build_stubbed(:user, email: "batchuser@example.com") }
  let(:temp_file_path) { "spec/fixtures/csv/dynamic_data.csv" }

  let(:importer) do
    create(:bulkrax_importer_csv,
           user: user,
           field_mapping: Bulkrax.field_mappings["HykuAddons::CsvParser"],
           parser_klass: "HykuAddons::CsvParser",
           parser_fields: { "import_file_path" => temp_file_path },
           limit: 0)
  end

  after do
    File.delete(temp_file_path) if File.exist?(temp_file_path)
  end

  before do
    # Make sure default admin set exists
    AdminSet.find_or_create_default_admin_set_id
    stub_request(:get, Addressable::Template.new("#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/translate?uri=urn:uuid:{id}")).to_return(status: 200)
    allow(Hyrax::Hirmeos::HirmeosFileUpdaterJob).to receive(:perform_later)
    create_csv
  end

  describe "import works" do
    before do
      perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
        importer.import_collections
      end
    end

    it "imports works" do
      expect do
        perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
          importer.import_works
        end
      end.to change { model_name.constantize.count }.by(number_of_records)

      number_of_records.times.each do |i|
        work = model_name.constantize.where(source_identifier: "source-#{i}").first

        expect(work.id).to eq("id-#{i}")
      end
    end
  end

  private

    def create_columns
      data = schema_data.dup
      data.delete_if { |_k, v| v.key?("subfields") }
      data.merge!(subfields)
    end

    def schema_data
      YAML.load_file("/home/app/config/metadata/ubiquity_template_work.yaml")["attributes"]
    end

    def subfields
      schema_data.map { |_k, v| v["subfields"] if v.key?("subfields") }
                 .compact
                 .reduce({}, :merge)
                 .transform_keys { |k| k + "_1" }
    end

    # TODO: Use factories to set default values

    def create_csv
      File.delete(temp_file_path) if File.exist?(temp_file_path)
      file = File.new(temp_file_path, "wb")

      csv = CSV.open(file, "wb", headers: headers, write_headers: true) do |row|
        number_of_records.times.each do |i|
          row << ["id-#{i}", "source-#{i}", model_name, depositor] + required_field_data(i)
        end
      end

      file.close

      csv
    end

    def headers
      # TODO: get value for resource type
      %w[id source_identifier model depositor] + required_attributes.keys - ["resource_type"]
    end

    def required_field_data(i)
      ["Title", "Personal", "creator_family_name-#{i}", "creator_given_name-#{i}", "creator_organization_name-#{i}"]
    end
end
