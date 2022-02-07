# frozen_string_literal: true

require "rails_helper"
require "csv"
require HykuAddons::Engine.root.join("spec", "support", "bulkrax",  "csv_reader_helper.rb").to_s
require HykuAddons::Engine.root.join("spec", "support", "bulkrax",  "csv_writer_helper.rb").to_s

# rubocop:disable RSpec/InstanceVariable
RSpec.describe "Bulkrax import", clean: true, slow: true do
  let(:user) { create(:user, email: "test@example.com") }
  let(:depositor) { build_stubbed(:user, email: "batchuser@example.com") }

  let(:number_of_records) { 3 } # Setting this too high will increase the test time for little gain

  after do
    ["UbiquityTemplateWork", "UvaWork"].each do |model_name|
      File.delete("spec/fixtures/csv/#{model_name.underscore}_dynamic_data.csv") if File.exist?("spec/fixtures/csv/#{model_name.underscore}_dynamic_data.csv")
    end
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
end
# rubocop:enable RSpec/InstanceVariable
