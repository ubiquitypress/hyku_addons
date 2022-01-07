# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::Forms::CollectionForm do
  let(:collection) { build :collection }
  let(:form) { described_class.new(collection, nil, nil) }

  describe "#required_fields" do
    subject { form.required_fields }

    it { is_expected.to eq [:title] }
  end

  describe "#terms" do
    subject { form.terms }

    it do
      is_expected.to eq [
        :resource_type, :title, :creator, :contributor, :description, :keyword, :license,
        :publisher, :date_created, :subject, :language, :representative_id, :thumbnail_id,
        :identifier, :based_near, :related_url, :visibility, :collection_type_gid
      ]
    end
  end

  describe "#primary_terms" do
    subject { form.primary_terms }

    it { is_expected.to eq([:title, :description]) }
  end

  describe "#secondary_terms" do
    subject { form.secondary_terms }

    it do
      is_expected.to eq [
        :creator, :contributor, :keyword, :license, :publisher, :date_created,
        :subject, :language, :identifier, :based_near, :related_url, :resource_type
      ]
    end
  end

  describe ".model_attributes" do
    subject(:model_attributes) { described_class.model_attributes(params) }

    let(:params) { ActionController::Parameters.new(attributes) }
    let(:attributes) do
      {
        title: ["foo"],
        subject: ["bar"]
      }
    end

    it "permits parameters" do
      expect(model_attributes["title"]).to eq ["foo"]
      expect(model_attributes["subject"]).to eq ["bar"]
    end

    context ".model_attributes" do
      let(:params) do
        ActionController::Parameters.new(
          title: [""],
          license: [""],
          related_url: [""],
          keyword: ["not_blank"],
          creator: [
            { "creator_name_type" => "Personal", "creator_given_name" => "Alice", "creator_family_name" => "Coltrane" },
            {}
          ],
          contributor: [{}]
        )
      end

      it "removes blank parameters" do
        expect(model_attributes["title"]).to be_empty
        expect(model_attributes["license"]).to be_empty
        expect(model_attributes["keyword"]).to eq ["not_blank"]
        expect(model_attributes["related_url"]).to be_empty
        expect(model_attributes["contributor"]).to be_empty
        expect(model_attributes["creator"]).to eq ["[{\"creator_given_name\":\"Alice\",\"creator_family_name\":\"Coltrane\",\"creator_name_type\":\"Personal\"},{}]"]
      end
    end
  end
end
