# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Bulkrax import", clean: true, perform_enqueued: true do
  let(:user) { create(:user, email: "test@example.com") }
  # let! is needed below to ensure that this user is created for file attachment because this is the depositor in the CSV fixtures
  let!(:depositor) { create(:user, email: "batchuser@example.com") }
  let(:importer) do
    create(:bulkrax_importer_csv,
           user: user,
           field_mapping: Bulkrax.field_mappings["HykuAddons::CsvParser"],
           parser_klass: "HykuAddons::CsvParser",
           parser_fields: { "import_file_path" => import_batch_file },
           limit: 0)
  end
  let(:import_batch_file) { "spec/fixtures/csv/pacific_articles.metadata.csv" }
  # let(:field_mapping) do
  #   {
  #     "date_published" => { "from" => ["date_published"], "split" => true, "parsed" => true, "if" => nil, "excluded" => false },
  #     # Is this admin set mapping really necessary?
  #     # "" => { "from" => ["admin_set"], "split" => false, "parsed" => false, "if" => nil, "excluded" => true }
  #   }
  # end

  before do
    # Make sure default admin set exists
    AdminSet.find_or_create_default_admin_set_id
    stub_request(:get, Addressable::Template.new("#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/translate?uri=urn:uuid:{id}")).to_return(status: 200)
    stub_request(:any, "#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/works")
    allow(Hyrax::Hirmeos::HirmeosFileUpdaterJob).to receive(:perform_later)
    allow(Hyrax::Hirmeos::HirmeosFileSetRegistrationJob).to receive(:perform_later)
  end

  describe "import works" do
    before do
      importer.import_collections
    end

    it "imports works" do
      expect { importer.import_works }.to change { PacificArticle.count }.by(2)
    end

    it "populates all fields" do
      importer.import_works
      work = PacificArticle.find("c109b1ff-6d9a-4498-b86c-190e7dcbe2e0")
      expect(work.title).to eq ["Bourdieu's Art"]
      expect(work.date_published).to eq "2010-1-1"
      expect(work.resource_type).to eq ["Research Article"]
      expect(work.subject).to eq ["Social Sciences", "Performing arts", "Music"]
      expect(work.license).to eq ["https://commons.pacificu.edu/rights"]
      expect(work.publisher).to eq ["Pacific University Press", "Ubiquity Press"]
      expect(work.depositor).to eq "batchuser@example.com"

      creators = JSON.parse(work.creator.first)
      creator = creators.first
      expect(creators).not_to be_empty
      expect(creators.size).to eq 1
      expect(creator["creator_family_name"]).to eq "Wilkes"
      expect(creator["creator_given_name"]).to eq "Christopher"
      expect(creator["creator_institutional_relationship"]).to eq "Pacific University"
      expect(creator["creator_middle_name"]).to eq "D"
      expect(creator["creator_name_type"]).to eq "Personal"
    end

    context "for an articles" do
      let(:account) { FactoryBot.create(:account, locale_name: "anschutz") }
      let(:import_batch_file) { "spec/fixtures/csv/anschutz.csv" }

      before do
        Site.update(account: account)
      end

      it "populates the fields" do
        importer.import_works
        work = AnschutzWork.last
        %w[advisor mesh subject_text citation references medium comittee_member time qualification_subject_text add_info].each do |field|
          next unless (val = work.try(field))
          expect(val).to eq(["#{field}1", "#{field}2"])
        end
      end
    end

    context "resource_type" do
      let(:import_batch_file) { "spec/fixtures/csv/generic_work.csv" }

      it "populates resource_type" do
        importer.import_works
        work = GenericWork.last
        expect(work.resource_type).to eq ["Interactive resource"]
      end
    end

    context "language" do
      let(:account) { FactoryBot.create(:account, locale_name: "redlands") }
      let(:import_batch_file) { "spec/fixtures/csv/redlands_article.csv" }

      before do
        Site.update(account: account)
      end

      it "populates language" do
        importer.import_works
        work = RedlandsArticle.last
        expect(work.language).to eq ["eng", "ara", "zho", "fra", "rus", "spa", "Other"]
      end
    end

    context "with files" do
      let(:import_batch_file) { "spec/fixtures/csv/pacific_articles.csv" }

      it "is valid" do
        expect(importer.valid_import?).to eq true
        expect(importer.parser.file_paths).to include "spec/fixtures/csv/files/nypl-hydra-of-lerna.jpg"
      end

      it "imports files" do
        # For some reason this has to be explictly set here and the meta tag in the top-most describe isn't sticking
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
        importer.import_works
        work = PacificArticle.find("c109b1ff-6d9a-4498-b86c-190e7dcbe2e0")
        expect(work.file_sets.size).to eq 1
        expect(work.file_sets.first.original_file.file_name).to eq ["nypl-hydra-of-lerna.jpg"]
        expect(work.file_sets.first.visibility).to eq "open"
      end

      context "with an alternate file path location" do
        let(:path_to_files) { Rails.root.join("tmp", "importer") }

        before do
          allow(ENV).to receive(:[]).and_call_original
          allow(ENV).to receive(:[]).with("BULKRAX_FILE_PATH").and_return(path_to_files)
          FileUtils.mkdir_p path_to_files
          FileUtils.cp_r "spec/fixtures/csv/files/.", path_to_files
        end

        after do
          FileUtils.rm_rf path_to_files
        end

        it "is valid" do
          expect(importer.valid_import?).to eq true
          expect(importer.parser.file_paths).to include File.join(path_to_files, "nypl-hydra-of-lerna.jpg")
        end

        it "imports files" do
          # For some reason this has to be explictly set here and the meta tag in the top-most describe isn't sticking
          ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
          importer.import_works
          work = PacificArticle.find("c109b1ff-6d9a-4498-b86c-190e7dcbe2e0")
          expect(work.file_sets.size).to eq 1
          expect(work.file_sets.first.original_file.file_name).to eq ["nypl-hydra-of-lerna.jpg"]
        end
      end

      context "file visibility" do
        let(:import_batch_file) { "spec/fixtures/csv/generic_work.file_set.csv" }

        it "imports files" do
          # For some reason this has to be explictly set here and the meta tag in the top-most describe isn't sticking
          ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
          importer.import_works
          work = GenericWork.first
          expect(work.visibility).to eq "open"
          expect(work.file_sets.size).to eq 3
          expect(work.ordered_members.to_a.first.title).to eq ["Lerna"]
          expect(work.ordered_members.to_a.first.visibility).to eq "restricted"
          expect(work.ordered_members.to_a.second.visibility).to eq "open"
          expect(work.ordered_members.to_a.second.title).to eq ["nypl-hydra-of-lerna.jpg"]
          expect(work.ordered_members.to_a.third.visibility).to eq "authenticated"
          expect(work.ordered_members.to_a.third.embargo_release_date).to eq "2029-07-01"
          expect(work.ordered_members.to_a.third.visibility_after_embargo).to eq "open"
        end
      end
    end
  end

  describe "import collections" do
    it "creates collections" do
      importer.import_collections
      expect(Collection.exists?("e51dbdd3-11bd-47f6-b00a-8aace969f2ab")).to eq true
    end
  end

  describe "full import" do
    it "creates collections and works" do
      expect { Bulkrax::ImporterJob.perform_now(importer.id) }.to change { Collection.count }.by(2).and change { PacificArticle.count }.by(2)
      # Check that created works are in created collection
      collection = Collection.find("e51dbdd3-11bd-47f6-b00a-8aace969f2ab")
      work = PacificArticle.find("c109b1ff-6d9a-4498-b86c-190e7dcbe2e0")
      expect(work.member_of_collections).to include collection

      # Check that other work is created
      work_with_multiple_collections = PacificArticle.find("54237483-f9d9-4b03-8867-812eb58bd4ac")
      other_collection = Collection.find("bedd7330-5040-4687-8226-0851f7256dff")
      expect(work_with_multiple_collections.member_of_collections).to include other_collection
      expect(work_with_multiple_collections.member_of_collections).to include collection
    end

    context "with admin sets" do
      let(:import_batch_file) { "spec/fixtures/csv/pacific_articles.admin_set.csv" }

      it "imports admin sets, collections, and works" do
        expect { Bulkrax::ImporterJob.perform_now(importer.id) }.to change { Collection.count }.by(2).and change { AdminSet.count }.by(1).and change { PacificArticle.count }.by(2)
        expect(AdminSet.where(title: "Default Admin Set").count).to eq 1
        expect(AdminSet.where(title: "History").count).to eq 1
        # Check that created works are in created collection
        default_admin_set = AdminSet.where(title: "Default Admin Set").first
        history_admin_set = AdminSet.where(title: "History").first
        default_collection = Collection.find("e51dbdd3-11bd-47f6-b00a-8aace969f2ab")
        history_collection = Collection.find("bedd7330-5040-4687-8226-0851f7256dff")
        work1 = PacificArticle.find("c109b1ff-6d9a-4498-b86c-190e7dcbe2e0")
        work2 = PacificArticle.find("54237483-f9d9-4b03-8867-812eb58bd4ac")
        expect(work1.member_of_collections).to include default_collection
        expect(work1.admin_set).to eq default_admin_set
        expect(work2.member_of_collections).to include history_collection
        expect(work2.admin_set).to eq history_admin_set
      end
    end
  end

  describe "identifiers" do
    context "when only source_identifier is present" do
      let(:import_batch_file) { "spec/fixtures/csv/generic_work.csv" }
      let(:source_identifier) { "external-id-1" }

      it "mints a new id" do
        expect { Bulkrax::ImporterJob.perform_now(importer.id) }.to change { GenericWork.count }.by(1)
        work = GenericWork.where(source_identifier: source_identifier).first
        expect(work.id).not_to eq source_identifier
      end
    end
  end

  describe "hyrax_record" do
    context "with identifiers" do
      it "returns the work created" do
        Bulkrax::ImporterJob.perform_now(importer.id)
        importer.entries.each do |entry|
          next unless entry.is_a?(HykuAddons::CsvEntry)
          work = PacificArticle.find(entry.identifier)
          expect(entry.hyrax_record).to eq work
        end
      end
    end

    context "when only source_identifier is present" do
      let(:import_batch_file) { "spec/fixtures/csv/generic_work.csv" }
      let(:source_identifier) { "external-id-1" }

      it "return the work imported" do
        Bulkrax::ImporterJob.perform_now(importer.id)
        importer.entries.each do |entry|
          next unless entry.is_a?(HykuAddons::CsvEntry)
          work = GenericWork.all.first
          expect(entry.hyrax_record).to eq work
        end
      end
    end
  end
end
