# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Bulkrax export", clean: true, perform_enqueued: true do
  let(:user) { create(:user, email: "test@example.com") }
  # let! is needed below to ensure that this user is created for file attachment because this is the depositor in the CSV fixtures
  let!(:depositor) { create(:user, email: "batchuser@example.com") }
  let(:exporter) do
    create(:bulkrax_exporter_worktype,
           user: user,
           field_mapping: Bulkrax.field_mappings["HykuAddons::CsvParser"],
           parser_klass: "HykuAddons::CsvParser",
           export_source: work.class.to_s,
           limit: 0)
  end
  let(:work) { create(:fully_described_work, user: depositor.email) }
  let(:account) { create(:account) }

  before do
    # Make sure default admin set exists
    AdminSet.find_or_create_default_admin_set_id
  end

  after do
    # TODO: cleanup export files and path
  end

  describe "export job" do
    before do
      work
      Bulkrax::ExporterJob.perform_now(exporter.id)
    end

    it "creates csv and zip" do
      expect(File.exist?(exporter.parser.setup_export_file)).to be_truthy
      expect(File.exist?(exporter.exporter_export_zip_path)).to eq true
      expect(File.readlines(exporter.parser.setup_export_file).size).to eq 2
    end
  end

  describe "single object export" do
    subject(:parsed_metadata) { entry.parsed_metadata }
    let(:entry) { exporter.entries.first }

    before do
      work
      exporter.export
    end

    it "populates all fields" do
      expect(parsed_metadata["id"]).to eq work.id
      expect(parsed_metadata["source_identifier"]).to eq work.id
      expect(parsed_metadata["model"]).to eq "GenericWork"
      expect(parsed_metadata["depositor"]).to eq depositor.email
      expect(parsed_metadata["pagination"]).to eq "1"
      expect(parsed_metadata["event_date"]).to eq "2009"
      expect(parsed_metadata["related_exhibition_date"]).to eq "2009"
      expected_dois = ["3-921099-34-X", "doi:10.1038/nphys1170", "ISBN:978-83-7659-303-6", "9790879392788",
                       "3-540-49698-x", "0-19-852663-6", "978-3-540-49698-4"]
      expect(parsed_metadata["identifier"].split("|")).to contain_exactly(*expected_dois)
    end
  end

  describe "round-tripping" do
    let(:exporter) do
      create(:bulkrax_exporter_worktype,
             user: user,
             field_mapping: Bulkrax.field_mappings["HykuAddons::CsvParser"],
             parser_klass: "HykuAddons::CsvParser",
             export_source: export_source,
             limit: nil)
    end

    let(:importer) do
      create(:bulkrax_importer_csv,
             user: user,
             field_mapping: Bulkrax.field_mappings["HykuAddons::CsvParser"],
             parser_klass: "HykuAddons::CsvParser",
             parser_fields: { "import_file_path" => import_batch_file },
             limit: nil)
    end
    let(:import_batch_file) { "spec/fixtures/csv/pacific_articles.metadata.csv" }
    let(:export_batch_file) { exporter.parser.setup_export_file }
    let(:export_source) { "PacificArticle" }

    before do
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
      stub_request(:get, Addressable::Template.new("#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/translate?uri=urn:uuid:{id}")).to_return(status: 200)
      allow(Hyrax::Hirmeos::HirmeosFileUpdaterJob).to receive(:perform_later)
      importer.import_collections
      importer.import_works
      exporter.export
      exporter.write
    end

    it "exports all fields" do
      entry = exporter.entries.find { |e| e.identifier == "c109b1ff-6d9a-4498-b86c-190e7dcbe2e0" }
      expect(entry).to be_present
      expect(entry.parsed_metadata["id"]).to eq "c109b1ff-6d9a-4498-b86c-190e7dcbe2e0"
      expect(entry.parsed_metadata["source_identifier"]).to eq "c109b1ff-6d9a-4498-b86c-190e7dcbe2e0"
      expect(entry.parsed_metadata["title"]).to eq "Bourdieu's Art"
      expect(entry.parsed_metadata["date_published"]).to eq "2010-1-1"
      expect(entry.parsed_metadata["creator_family_name_1"]).to eq "Wilkes"
      expect(entry.parsed_metadata["creator_given_name_1"]).to eq "Christopher"
      expect(entry.parsed_metadata["creator_middle_name_1"]).to eq "D"
      expect(entry.parsed_metadata["creator_name_type_1"]).to eq "Personal"
      expect(entry.parsed_metadata["creator_institutional_relationship_1"]).to eq "Pacific University"
      expect(entry.parsed_metadata["resource_type"]).to eq "Research Article"
      expect(entry.parsed_metadata["license"]).to eq "https://commons.pacificu.edu/rights"
      expect(entry.parsed_metadata["publisher"].split("|")).to contain_exactly("Pacific University Press", "Ubiquity Press")
      expect(entry.parsed_metadata["depositor"]).to eq "batchuser@example.com"
    end

    it "round-trips" do
      import_csv_array = CSV.read(import_batch_file)
      export_csv_array = CSV.read(export_batch_file)

      import_headers = import_csv_array.delete_at(0)
      export_headers = export_csv_array.delete_at(0)

      # Compare headers (except file)
      expect(export_headers).to include(*import_headers.without("file"))
      import_header_id = import_headers.index("id")
      export_header_id = export_headers.index("id")

      # Compare values
      import_entries = import_csv_array.sort_by(&:first)
      export_entries = export_csv_array.sort_by(&:first)

      export_entries.each do |export_entry|
        import_entry = import_entries.find { |e| e[import_header_id] == export_entry[export_header_id] }

        import_headers.each_with_index do |field, col|
          next if field == "file" # TODO: Add matching for this?
          export_col = export_headers.index(field)
          # Handle multi-valued fields by spliting on both sides and using contain_exactly
          expect(Array(export_entry[export_col].presence&.split("|"))).to contain_exactly(*Array(import_entry[col].presence&.split("|")))
        end
      end
    end

    context 'file visibility' do
      let(:import_batch_file) { 'spec/fixtures/csv/generic_work.file_set.csv' }
      let(:export_source) { "GenericWork" }

      it 'imports files' do
        entry = exporter.entries.first
        expect(entry).to be_present
        expect(entry.parsed_metadata['visibility']).to eq 'open'
        expect(entry.parsed_metadata['file_1']).to end_with 'nypl-hydra-of-lerna.jpg'
        expect(entry.parsed_metadata['file_visibility_1']).to eq 'restricted'
        expect(entry.parsed_metadata['file_2']).to end_with 'nypl-hydra-of-lerna.jpg'
        expect(entry.parsed_metadata['file_visibility_2']).to eq 'open'
        expect(entry.parsed_metadata['file_3']).to end_with 'nypl-hydra-of-lerna.jpg'
        expect(entry.parsed_metadata['file_visibility_3']).to eq 'embargo'
        expect(entry.parsed_metadata['file_embargo_release_date_3']).to eq '2029-07-01'
        expect(entry.parsed_metadata['file_visibility_during_embargo_3']).to eq 'authenticated'
        expect(entry.parsed_metadata['file_visibility_after_embargo_3']).to eq 'open'
      end
    end
  end
end
