# frozen_string_literal: true
require "rails_helper"

RSpec.describe Bolognese::Readers::UbiquityGenericWorkReader do
  let(:identifier) { '123456' }
  let(:doi) { '10.18130/v3-k4an-w022' }
  let(:title) { 'Moomin' }
  let(:creator) { 'Tove Jansson' }
  let(:contributor) { 'Elizabeth Portch' }
  let(:publisher) { 'Schildts' }
  let(:description) { 'Swedish comic about the adventures of the residents of Moominvalley.' }
  let(:keyword) { 'Lighthouses' }
  let(:created_date) { 1945 }

  let(:model_class) { Class.new(GenericWork) }
  let(:work) { model_class.new(attributes) }

  let(:attributes) do
    {
      identifier: [identifier],
      doi: [doi],
      title: [title],
      creator: [creator],
      contributor: [contributor],
      publisher: [publisher],
      description: [description],
      keyword: [keyword],
      date_created: [created_date]
    }
  end

  let(:metadata_class) do
    Class.new(Bolognese::Metadata) do
      include Bolognese::Readers::UbiquityGenericWorkReader
    end
  end

  let(:input) { work.attributes.merge(has_model: work.has_model.first).to_json }
  let(:metadata) { metadata_class.new(input: input, from: "ubiquity_generic_work") }

  it "reads a GenericWork" do
    expect(metadata).to be_a(Bolognese::Metadata)
  end

  describe "#read_ubiquity_generic_work" do
    it "responds to the method" do
      expect(metadata).to respond_to(:read_ubiquity_generic_work)
    end
  end

  context "crosswalks" do
    let(:data) { metadata.ris.split("\r\n") }

    it "correctly populates the export" do
      expect(data[0]).to eq("T1  - #{title}")
      expect(data[1]).to eq("DO  - https://doi.org/#{doi}")
      expect(data[2]).to eq("AB  - #{description}")
      expect(data[3]).to eq("KW  - #{keyword}")
      expect(data[4]).to eq("PY  - #{created_date}")
      expect(data[5]).to eq("PB  - #{publisher}")
      expect(data[6]).to eq("ER  - ")
    end
  end
end
