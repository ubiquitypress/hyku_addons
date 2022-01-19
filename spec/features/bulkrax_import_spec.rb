# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Bulkrax import", clean: true do
  let(:user) { create(:user, email: "test@example.com") }
  # let! is needed below to ensure that this user is created for file attachment because this is the depositor in the CSV fixtures
  let!(:depositor) { build_stubbed(:user, email: "batchuser@example.com") }
  let(:importer) do
    create(:bulkrax_importer_csv,
           user: user,
           field_mapping: Bulkrax.field_mappings["HykuAddons::CsvParser"],
           parser_klass: "HykuAddons::CsvParser",
           parser_fields: { "import_file_path" => import_batch_file },
           limit: 0)
  end
  let(:import_batch_file) { "spec/fixtures/csv/pacific_articles.metadata.csv" }

  before do
    # Make sure default admin set exists
    stub_request(:get, Addressable::Template.new("#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/translate?uri=urn:uuid:{id}")).to_return(status: 200)
    allow(Hyrax::Hirmeos::HirmeosFileUpdaterJob).to receive(:perform_later)
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
      end.to change { PacificArticle.count }.by(2)
    end

    it "populates all fields" do
      perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
        importer.import_works
      end

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
      let(:account) { build_stubbed(:account, locale_name: "anschutz") }
      let(:import_batch_file) { "spec/fixtures/csv/anschutz.csv" }

      before do
        Site.update(account: account)
      end

      it "populates the fields" do
        perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
          importer.import_works
        end

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
        perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
          importer.import_works
        end

        work = GenericWork.last
        expect(work.resource_type).to eq ["Interactive resource"]
      end
    end

    context "language" do
      let(:account) { build_stubbed(:account, locale_name: "redlands") }
      let(:import_batch_file) { "spec/fixtures/csv/redlands_article.csv" }

      before do
        AdminSet.find_or_create_default_admin_set_id
        Site.update(account: account)
      end

      it "populates language" do
        perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
          importer.import_works
        end
        work = RedlandsArticle.last
        expect(work.language).to eq ["eng", "ara", "zho", "fra", "rus", "spa", "Other"]
      end
    end
  end

  describe "import works with files" do
    let!(:depositor) { create(:user, email: "batchuser@example.com") }

    before do
      # Make sure default admin set exists
      AdminSet.find_or_create_default_admin_set_id
      perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
        importer.import_collections
      end
    end

    context "with files" do
      let(:import_batch_file) { "spec/fixtures/csv/pacific_articles.csv" }

      it "is valid" do
        expect(importer.valid_import?).to eq true
        expect(importer.parser.file_paths).to include "spec/fixtures/csv/files/nypl-hydra-of-lerna.jpg"
      end

      it "imports files" do
        perform_enqueued_jobs(only: [AttachFilesToWorkJob, IngestJob, FileSetAttachedEventJob]) do
          importer.import_works
        end

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
          perform_enqueued_jobs(only: [AttachFilesToWorkJob, IngestJob, FileSetAttachedEventJob]) do
            importer.import_works
          end

          work = PacificArticle.find("c109b1ff-6d9a-4498-b86c-190e7dcbe2e0")

          expect(work.file_sets.size).to eq 1
          expect(work.file_sets.first.original_file.file_name).to eq ["nypl-hydra-of-lerna.jpg"]
        end
      end

      context "file visibility" do
        let(:import_batch_file) { "spec/fixtures/csv/generic_work.file_set.csv" }

        it "imports files" do
          perform_enqueued_jobs(only: [AttachFilesToWorkJob, IngestJob, FileSetAttachedEventJob]) do
            importer.import_works
          end

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
    context "when the csv does not set the collection title" do
      it "creates collections" do
        perform_enqueued_jobs(only: [Bulkrax::ImporterJob, Bulkrax::ImportWorkCollectionJob]) do
          importer.import_collections
        end

        expect(Collection.exists?("e51dbdd3-11bd-47f6-b00a-8aace969f2ab")).to eq true
        expect(Collection.exists?("bedd7330-5040-4687-8226-0851f7256dff")).to eq true
        expect(Collection.find("e51dbdd3-11bd-47f6-b00a-8aace969f2ab").title).to eq(["New collection 1"])
        expect(Collection.find("bedd7330-5040-4687-8226-0851f7256dff").title).to eq(["New collection 2"])
      end
    end

    context "when the csv sets the collection title" do
      context "when the Bulkrax version is 2" do
        let(:import_batch_file) { "spec/fixtures/csv/pacific_articles_collection_title.metadata.csv" }

        it "creates collections with titles" do
          perform_enqueued_jobs(only: [Bulkrax::ImporterJob, Bulkrax::ImportWorkCollectionJob]) do
            importer.import_collections
          end

          expect(Collection.exists?("e51dbdd3-11bd-47f6-b00a-8aace969f2ab")).to eq true
          expect(Collection.exists?("bedd7330-5040-4687-8226-0851f7256dff")).to eq true
          expect(Collection.find("e51dbdd3-11bd-47f6-b00a-8aace969f2ab").title).to eq(["Title"])
          expect(Collection.find("bedd7330-5040-4687-8226-0851f7256dff").title).to eq(["Other title"])
        end
      end

      context "when the Bulkrax version is 3" do
        let(:import_batch_file) { "spec/fixtures/csv/pacific_articles_parent_title.metadata.csv" }
        # rubocop:disable RSpec/MessageChain
        it "uses parent_ column prefix" do
          allow(Gem).to receive_message_chain(:loaded_specs, :[]).with("bulkrax").and_return(instance_double(Bundler::StubSpecification, version: Gem::Version.create("3.0")))

          perform_enqueued_jobs(only: [Bulkrax::ImporterJob, Bulkrax::ImportWorkCollectionJob]) do
            importer.import_collections
          end

          expect(Collection.exists?("e51dbdd3-11bd-47f6-b00a-8aace969f2ab")).to eq true
          expect(Collection.exists?("bedd7330-5040-4687-8226-0851f7256dff")).to eq true
          expect(Collection.find("e51dbdd3-11bd-47f6-b00a-8aace969f2ab").title).to eq(["Title"])
          expect(Collection.find("bedd7330-5040-4687-8226-0851f7256dff").title).to eq(["Other title"])
        end
      end
    end
  end

  describe "full import" do
    it "creates collections and works" do
      expect do
        perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
          Bulkrax::ImporterJob.perform_now(importer.id)
        end
      end.to change { Collection.count }.by(2).and change { PacificArticle.count }.by(2)
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
        AdminSet.find_or_create_default_admin_set_id

        expect do
          perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
            Bulkrax::ImporterJob.perform_now(importer.id)
          end
        end.to change { Collection.count }.by(2).and change { AdminSet.count }.by(1).and change { PacificArticle.count }.by(2)

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
        expect do
          perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
            Bulkrax::ImporterJob.perform_now(importer.id)
          end
        end.to change { GenericWork.count }.by(1)
        work = GenericWork.where(source_identifier: source_identifier).first
        expect(work.id).not_to eq source_identifier
      end
    end
  end

  describe "doi minting" do
    let(:import_batch_file) { "spec/fixtures/csv/generic_work_with_doi.csv" }
    let(:prefix) { "10.1234" }
    let(:suffix) { "abcdef" }
    let(:doi) { "#{prefix}/#{suffix}" }
    let(:response_body) { File.read(HykuAddons::Engine.root.join("spec", "fixtures", "doi", "mint_doi_return_body.json")) }

    before do
      Rails.application.routes.default_url_options[:host] = "example.com"
      Hyrax.config.identifier_registrars = { datacite: Hyrax::DOI::DataCiteRegistrar }
      Hyrax::DOI::DataCiteRegistrar.mode = :test
      Hyrax::DOI::DataCiteRegistrar.prefix = prefix
      Hyrax::DOI::DataCiteRegistrar.username = "username"
      Hyrax::DOI::DataCiteRegistrar.password = "password"

      stub_request(:post, URI.join(Hyrax::DOI::DataCiteClient::TEST_BASE_URL, "dois"))
        .with(headers: { "Content-Type" => "application/vnd.api+json" },
              basic_auth: ["username", "password"],
              body: "{\"data\":{\"type\":\"dois\",\"attributes\":{\"prefix\":\"#{prefix}\"}}}")
        .to_return(status: 201, body: response_body)

      stub_request(:put, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "metadata/#{doi}"))
        .with(headers: { 'Content-Type': "application/xml;charset=UTF-8" },
              basic_auth: ["username", "password"])
        .to_return(status: 201, body: "OK (#{doi})")

      stub_request(:put, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "doi/#{doi}"))
        .with(headers: { 'Content-Type': "text/plain;charset=UTF-8" },
              basic_auth: ["username", "password"])
        .to_return(status: 201, body: "")

      stub_request(:delete, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "metadata/#{doi}"))
        .with(
          headers: {
            "Accept" => "*/*",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Authorization" => "Basic dXNlcm5hbWU6cGFzc3dvcmQ=",
            "User-Agent" => "Faraday v0.17.4"
          }
        )
        .to_return(status: 200, body: "", headers: {})
    end

    context "when import_mode is enabled" do
      it "calls the DOI Job" do
        allow(Flipflop).to receive(:enabled?).and_call_original
        allow(Flipflop).to receive(:enabled?).with(:import_mode).and_return(true).at_least(:once)

        allow(Apartment::Tenant).to receive(:current).and_return("x")
        allow(Account).to receive(:find_by).with(tenant: "x").and_return(instance_double(Account, name: "x"))
        allow(Apartment::Tenant).to receive(:switch).with("x") do |&block|
          block.call
        end

        allow(Hyrax::DOI::RegisterDOIJob).to receive(:perform_later).and_call_original
        allow(Hyrax::Identifier::Dispatcher).to receive(:for).and_call_original

        perform_enqueued_jobs(only: [Bulkrax::ImporterJob, Hyrax::DOI::RegisterDOIJob]) do
          Bulkrax::ImporterJob.perform_now(importer.id)
        end

        expect(Flipflop).to have_received(:enabled?).with(:import_mode).at_least(:once)

        # This tests that the job is enqueued
        expect(Hyrax::DOI::RegisterDOIJob).to have_received(:perform_later).exactly(12).times
        # This tests that the job is actually performed, as its only step is to call this class.
        expect(Hyrax::Identifier::Dispatcher).to have_received(:for).exactly(12).times
      end
    end

    context "when the work does not exist" do
      it "mints DOIs for all applicable rows" do
        perform_enqueued_jobs(only: [Bulkrax::ImporterJob, Hyrax::DOI::RegisterDOIJob]) do
          Bulkrax::ImporterJob.perform_now(importer.id)
        end

        expect(GenericWork.all.pluck(:doi)).to eq([[], [], ["10.1234/abcdef"], [], ["10.1234/abcdef"], ["10.1234/abcdef"], [], ["10.1234/abcdef"], ["10.1234/abcdef"], ["10.1234/abcdef"], ["10.1234/abcdef"], ["10.1234/abcdef"]])
        expect(GenericWork.all.pluck(:doi_status_when_public)).to eq([nil, nil, "draft", nil, "draft", "registered", nil, "draft", "registered", "findable", "findable", "findable"])
      end
    end

    context "when the works already exist" do
      let(:prefix) { "10.5678" }
      let(:response_body) { File.read(HykuAddons::Engine.root.join("spec", "fixtures", "doi", "mint_doi_return_body2.json")) }
      let(:body) { "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<resource xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://datacite.org/schema/kernel-4\" xsi:schemaLocation=\"http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4/metadata.xsd\">\n  <identifier identifierType=\"DOI\"/>\n  <creators>\n    <creator>\n      <creatorName/>\n    </creator>\n    <creator>\n      <creatorName>Poppins, Mary</creatorName>\n      <givenName>Mary</givenName>\n      <familyName>Poppins</familyName>\n    </creator>\n  </creators>\n  <titles>\n    <title>Abstract search test - Mary Poppins</title>\n  </titles>\n  <publisher>:unav</publisher>\n  <publicationYear>2022</publicationYear>\n  <resourceType resourceTypeGeneral=\"Other\">[\"Interactive resource\"]</resourceType>\n  <sizes/>\n  <formats/>\n  <version/>\n</resource>\n" }

      before do
        stub_request(:put, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "metadata/#{doi}"))
          .with(
            body: body,
            headers: {
              "Accept" => "*/*",
              "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "Authorization" => "Basic dXNlcm5hbWU6cGFzc3dvcmQ=",
              "Content-Type" => "application/xml;charset=UTF-8",
              "User-Agent" => "Faraday v0.17.4"
            }
          )
          .to_return(status: 200, body: "", headers: {})
      end

      context "when the work already has a DOI" do
        context "the import does not change the DOI status backwards" do
          let!(:work_1) { create :work, source_identifier: "external-id-1", doi: nil, doi_status_when_public: nil }
          let!(:work_2) { create :work, source_identifier: "external-id-2", doi: [doi], doi_status_when_public: "draft" }
          let!(:work_3) { create :work, source_identifier: "external-id-3", doi: [doi], doi_status_when_public: "draft" }
          let!(:work_4) { create :work, source_identifier: "external-id-4", doi: [doi], doi_status_when_public: "registered" }
          let!(:work_5) { create :work, source_identifier: "external-id-5", doi: [doi], doi_status_when_public: "registered" }
          let!(:work_6) { create :work, source_identifier: "external-id-6", doi: [doi], doi_status_when_public: "registered" }
          let!(:work_7) { create :work, source_identifier: "external-id-7", doi: [doi], doi_status_when_public: "findable" }
          let!(:work_8) { create :work, source_identifier: "external-id-8", doi: [doi], doi_status_when_public: "findable" }
          let!(:work_9) { create :work, source_identifier: "external-id-9", doi: [doi], doi_status_when_public: "findable" }
          let!(:work_10) { create :work, source_identifier: "external-id-10", doi: [doi], doi_status_when_public: "findable" }

          it "does not mint a new DOI" do
            perform_enqueued_jobs(only: [Bulkrax::ImporterJob, Hyrax::DOI::RegisterDOIJob]) do
              Bulkrax::ImporterJob.perform_now(importer.id)
            end

            expect(work_1.reload.doi).to be_empty
            expect(work_2.reload.doi).to eq([doi])
            expect(work_3.reload.doi).to eq([doi])
            expect(work_3.reload.doi).to eq([doi])
            expect(work_4.reload.doi).to eq([doi])
            expect(work_5.reload.doi).to eq([doi])
            expect(work_6.reload.doi).to eq([doi])
            expect(work_7.reload.doi).to eq([doi])
            expect(work_8.reload.doi).to eq([doi])
            expect(work_9.reload.doi).to eq([doi])
            expect(work_10.reload.doi).to eq([doi])

            expect(work_1.doi_status_when_public).to be_nil
            expect(work_2.doi_status_when_public).to eq("draft")
            expect(work_3.doi_status_when_public).to eq("draft")
            expect(work_4.doi_status_when_public).to eq("registered")
            expect(work_5.doi_status_when_public).to eq("registered")
            expect(work_6.doi_status_when_public).to eq("registered")
            expect(work_7.doi_status_when_public).to eq("findable")
            expect(work_8.doi_status_when_public).to eq("findable")
            expect(work_9.doi_status_when_public).to eq("findable")
            expect(work_10.doi_status_when_public).to eq("findable")
          end
        end

        context "the import changes the DOI status forwards" do
          let!(:work_8) { create :work, source_identifier: "external-id-8", doi:  nil, doi_status_when_public: nil }
          let!(:work_9) { create :work, source_identifier: "external-id-9", doi:  nil, doi_status_when_public: nil }
          let!(:work_10) { create :work, source_identifier: "external-id-10", doi: nil, doi_status_when_public: nil }
          let!(:work_6) { create :work, source_identifier: "external-id-6", doi: [doi], doi_status_when_public: "draft" }
          let!(:work_11) { create :work, source_identifier: "external-id-11", doi: [doi], doi_status_when_public: "draft" }
          let!(:work_12) { create :work, source_identifier: "external-id-12", doi: [doi], doi_status_when_public: "registered" }

          it "changes DOI status and mints only for the correct items" do
            perform_enqueued_jobs(only: [Bulkrax::ImporterJob, Hyrax::DOI::RegisterDOIJob]) do
              Bulkrax::ImporterJob.perform_now(importer.id)
            end

            expect(work_6.reload.doi).to eq([doi])
            expect(work_8.reload.doi).to eq([doi])
            expect(work_9.reload.doi).to eq([doi])
            expect(work_10.reload.doi).to eq([doi])
            expect(work_11.reload.doi).to eq([doi])
            expect(work_12.reload.doi).to eq([doi])

            # An existing work without a DOI can move to draft, registered or findable
            expect(work_8.doi_status_when_public).to eq("draft")
            expect(work_9.doi_status_when_public).to eq("registered")
            expect(work_10.doi_status_when_public).to eq("findable")

            # A draft work can move to registered or findable
            expect(work_6.doi_status_when_public).to eq("registered")
            expect(work_11.doi_status_when_public).to eq("findable")

            # A registered work can move to findable
            expect(work_12.doi_status_when_public).to eq("findable")
          end
        end
      end
    end
  end

  describe "hyrax_record" do
    context "with identifiers" do
      it "returns the work created" do
        perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
          Bulkrax::ImporterJob.perform_now(importer.id)
        end

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
        perform_enqueued_jobs(only: Bulkrax::ImporterJob) do
          Bulkrax::ImporterJob.perform_now(importer.id)
        end

        importer.entries.each do |entry|
          next unless entry.is_a?(HykuAddons::CsvEntry)
          work = GenericWork.all.first
          expect(entry.hyrax_record).to eq work
        end
      end
    end
  end
end
