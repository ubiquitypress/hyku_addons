# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bulkrax import', clean: true, perform_enqueued: true do
  let(:user) { User.new(email: 'test@example.com') }
  let(:account) { create(:account) }
  # let(:admin_set) { create(:admin_set) }
  let(:importer) do
    create(:bulkrax_importer_csv,
           user: user,
           #  admin_set_id: admin_set.id,
           field_mapping: field_mapping,
           parser_klass: "HykuAddons::CsvParser",
           parser_fields: { 'import_file_path' => import_batch_file },
           limit: 0)
  end
  let(:import_batch_file) { 'spec/fixtures/csv/pacific_articles.csv' }
  let(:field_mapping) do
    {
      # "title" => {"from"=>["title"], "split"=>true, "parsed"=>false, "if"=>nil, "excluded"=>false},
      "date_published" => { "from" => ["date_published_1"], "split" => true, "parsed" => true, "if" => nil, "excluded" => false },
      "" => { "from" => ["admin_set"], "split" => false, "parsed" => false, "if" => nil, "excluded" => true }
    }
  end

  before do
    account
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
      expect(work.resource_type).to eq ["Research Article"]
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
  end
end
