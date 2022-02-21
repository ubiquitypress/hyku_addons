# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe "Bulkrax import", clean: true, slow: true do
  include CsvWriterHelper
  include CsvReaderHelper

  let(:user) { create(:user, email: "test@test.com") }
  let(:depositor) { build_stubbed(:user, email: "batchuser@test.com") }
  let(:account) { build_stubbed(:account) }
  let(:site) { Site.new(account: account) }

  # We cannot use let to memoize or share the model name because Rspec will not reset it when we iterate below
  attr_accessor :model_name

  let(:number_of_records) { 3 } # Setting this too high will increase the test time for little gain

  after do
    schema_work_types.each do |work_type|
      file = "spec/fixtures/csv/#{work_type.underscore}_dynamic_data.csv"
      File.delete(file) if File.exist?(file)
    end
  end

  schema_work_types.each do |work_type|
    let(:importer) do
      create(:bulkrax_importer_csv,
             user: user,
             field_mapping: Bulkrax.field_mappings["HykuAddons::CsvParser"],
             parser_klass: "HykuAddons::CsvParser",
             parser_fields: { "import_file_path" => temporary_file_path },
             limit: 0)
    end

    before do
      allow(Site).to receive(:instance).and_return(site)

      # Make sure default admin set exists
      AdminSet.find_or_create_default_admin_set_id
      url = "#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/translate?uri=urn:uuid:{id}"
      template = Addressable::Template.new(url)
      stub_request(:get, template).to_return(status: 200)
      allow(Hyrax::Hirmeos::HirmeosFileUpdaterJob).to receive(:perform_later)

      self.model_name = work_type
      create_csv
    end

    it "imports #{work_type} works" do
      expect do
        perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
          importer.import_collections
        end

        perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
          importer.import_works
        end
      end.to change { model_name.constantize.count }.by(number_of_records)

      aggregate_failures do
        CSV.read(temporary_file_path, headers: true).each do |row|
          work = model_name.constantize.where(source_identifier: row["source_identifier"]).first
          expectations = csv_row_to_expectations(row, work)

          expectations.each do |expectation|
            error_message = "expected #{expectation[:attribute_name]} to equal #{expectation[:test]} but got #{expectation[:actual]}"
            expect(expectation[:actual]).to eq(expectation[:test]), error_message
          end
        end
      end
    end
  end
end
