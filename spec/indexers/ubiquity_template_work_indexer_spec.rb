# frozen_string_literal: true

RSpec.describe UbiquityTemplateWorkIndexer do
  subject(:solr_document) { service.generate_solr_document }
  let(:service) { described_class.new(work) }
  let(:model_name) { :ubiquity_template_work }
  let(:model_class) { model_name.to_s.classify.constantize }
  let(:work) { model_class.new(attributes) }
  let(:schema) { Hyrax::SimpleSchemaLoader.new.attributes_config_for(schema: model_name) }
  let(:index_keys) { schema.values.map { |h| h["index_keys"] }.flatten.sort }

  let(:title) { "Moomin" }
  let(:alt_title) { "alt title" }
  let(:keyword) { "the keyword" }
  let(:resource_type) { "Book" }
  let(:creator1_first_name) { "Sebastian" }
  let(:creator1_last_name) { "Hageneuer" }
  let(:creator1_orcid) { "https://sandbox.orcid.org/0000-0003-0652-4625" }
  let(:creator1) do
    {
      creator_name_type: "Personal",
      creator_given_name: creator1_first_name,
      creator_family_name: creator1_last_name,
      creator_orcid: creator1_orcid
    }
  end
  let(:attributes) do
    {
      title: [title],
      alt_title: [alt_title],
      resource_type: [resource_type],
      creator: [[creator1].to_json],
      keyword: [keyword]
    }
  end

  it "indexes the correct fields" do
    attributes.each_key do |key|
      index_key = Array.wrap(schema.dig(key, "index_keys")).first

      expect(solr_document[index_key]).to eq attributes[key]
    end
  end

  # Sanity check to make sure its working elsewhere
  context "when the work is not schema driven" do
    let(:model_name) { :generic_work }

    it "indexes the correct fields" do
      attributes.each_key do |key|
        index_key = ::SolrDocument.solr_name(key)

        expect(solr_document[index_key]).to eq attributes[key]
      end
    end
  end
end
