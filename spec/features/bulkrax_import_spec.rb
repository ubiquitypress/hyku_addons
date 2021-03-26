# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bulkrax import', clean: true, perform_enqueued: true do
  let(:user) { create(:user, email: 'test@example.com') }
  # let! is needed below to ensure that this user is created for file attachment because this is the depositor in the CSV fixtures
  let!(:depositor) { create(:user, email: 'batchuser@example.com') }
  let(:account) { create(:account) }
  let(:importer) do
    create(:bulkrax_importer_csv,
           user: user,
           field_mapping: Bulkrax.field_mappings["HykuAddons::CsvParser"],
           parser_klass: "HykuAddons::CsvParser",
           parser_fields: { 'import_file_path' => import_batch_file },
           limit: 0)
  end
  let(:import_batch_file) { 'spec/fixtures/csv/pacific_articles.metadata.csv' }
  # let(:field_mapping) do
  #   {
  #     "date_published" => { "from" => ["date_published"], "split" => true, "parsed" => true, "if" => nil, "excluded" => false },
  #     # Is this admin set mapping really necessary?
  #     # "" => { "from" => ["admin_set"], "split" => false, "parsed" => false, "if" => nil, "excluded" => true }
  #   }
  # end

  before do
    account

    # Make sure default admin set exists
    AdminSet.find_or_create_default_admin_set_id
  end

  describe 'import works' do
    before do
      importer.import_collections
    end

    it 'imports works' do
      expect { importer.import_works }.to change { PacificArticle.count }.by(2)
    end

    it 'populates all fields' do
      importer.import_works
      work = PacificArticle.find('c109b1ff-6d9a-4498-b86c-190e7dcbe2e0')
      expect(work.title).to eq ["Bourdieu's Art"]
      expect(work.date_published).to eq "2010-1-1"
      expect(JSON.parse(work.creator.first)).to be_present
      expect(JSON.parse(work.creator.first).size).to eq 1
      expect(work.resource_type).to eq ["Research Article"]
      expect(work.license).to eq ["https://commons.pacificu.edu/rights"]
      expect(work.publisher).to eq ['Pacific University Press', 'Ubiquity Press']
      expect(work.depositor).to eq 'batchuser@example.com'
    end

    context 'with files' do
      let(:import_batch_file) { 'spec/fixtures/csv/pacific_articles.csv' }

      it 'imports files' do
        # For some reason this has to be explictly set here and the meta tag in the top-most describe isn't sticking
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
        importer.import_works
        work = PacificArticle.find('c109b1ff-6d9a-4498-b86c-190e7dcbe2e0')
        expect(work.file_sets.size).to eq 1
        expect(work.file_sets.first.original_file.file_name).to eq ["nypl-hydra-of-lerna.jpg"]
      end

      context 'with an alternate file path location' do
        let(:path_to_files) { Rails.root.join('tmp', 'importer') }

        before do
          allow(ENV).to receive(:[]).and_call_original
          allow(ENV).to receive(:[]).with("BULKRAX_FILE_PATH").and_return(path_to_files)
          FileUtils.mkdir_p path_to_files
          FileUtils.cp_r 'spec/fixtures/csv/files/.', path_to_files
        end

        after do
          FileUtils.rm_rf path_to_files
        end

        it 'imports files' do
          # For some reason this has to be explictly set here and the meta tag in the top-most describe isn't sticking
          ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
          importer.import_works
          work = PacificArticle.find('c109b1ff-6d9a-4498-b86c-190e7dcbe2e0')
          expect(work.file_sets.size).to eq 1
          expect(work.file_sets.first.original_file.file_name).to eq ["nypl-hydra-of-lerna.jpg"]
        end
      end
    end
  end

  describe 'import collections' do
    it 'creates collections' do
      importer.import_collections
      expect(Collection.exists?('e51dbdd3-11bd-47f6-b00a-8aace969f2ab')).to eq true
    end
  end

  describe 'full import' do
    it 'creates collections and works' do
      expect { Bulkrax::ImporterJob.perform_now(importer.id) }.to change { Collection.count }.by(1).and change { PacificArticle.count }.by(2)
      # Check that created works are in created collection
      collection = Collection.find('e51dbdd3-11bd-47f6-b00a-8aace969f2ab')
      work = PacificArticle.find('c109b1ff-6d9a-4498-b86c-190e7dcbe2e0')
      expect(work.member_of_collections).to include collection
      # Check that other work is created
      expect(PacificArticle.exists?('54237483-f9d9-4b03-8867-812eb58bd4ac')).to eq true
    end

    context 'with admin sets' do
      let(:import_batch_file) { 'spec/fixtures/csv/pacific_articles.admin_set.csv' }

      it 'imports admin sets, collections, and works' do
        expect { Bulkrax::ImporterJob.perform_now(importer.id) }.to change { Collection.count }.by(2).and change { AdminSet.count }.by(1).and change { PacificArticle.count }.by(2)
        expect(AdminSet.where(title: 'Default Admin Set').count).to eq 1
        expect(AdminSet.where(title: 'History').count).to eq 1
        # Check that created works are in created collection
        default_admin_set = AdminSet.where(title: 'Default Admin Set').first
        history_admin_set = AdminSet.where(title: 'History').first
        default_collection = Collection.find('e51dbdd3-11bd-47f6-b00a-8aace969f2ab')
        history_collection = Collection.find('bedd7330-5040-4687-8226-0851f7256dff')
        work1 = PacificArticle.find('c109b1ff-6d9a-4498-b86c-190e7dcbe2e0')
        work2 = PacificArticle.find('54237483-f9d9-4b03-8867-812eb58bd4ac')
        expect(work1.member_of_collections).to include default_collection
        expect(work1.admin_set).to eq default_admin_set
        expect(work2.member_of_collections).to include history_collection
        expect(work2.admin_set).to eq history_admin_set
      end
    end
  end
end
