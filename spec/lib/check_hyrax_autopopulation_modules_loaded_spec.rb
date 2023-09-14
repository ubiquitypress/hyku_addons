# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/DescribeClass
RSpec.describe "Hyrax-autopopulation " do
  describe "loaded modules" do
    context "Adds Hyrax::Autopopulation::AutopopulationProperty module" do
      Hyrax.config.registered_curation_concern_types.map do |work|
        it "has autopopulation_status in #{work}" do
          expect { work.constantize.new.autopopulation_status }.not_to raise_error(NoMethodError)
        end
      end

      context "Bolognese::Writers::HyraxWorkActorAttributes" do
        let(:attributes) do
          {
            doi: ["10.1117/12.2004063"],
            title: ["Single-cell photoacoustic thermometry"],
            date_published: [{ "date_published_year" => "2015", "date_published_month" => "5",
                               "date_published_day" => "29" }],
            publisher: ["SPIE-Intl Soc Optical Eng"],
            creator: [{ "creator_name_type" => "Personal", "creator_given_name" => "Liang", "creator_family_name" => "Gao", "creator_position" => 0 },
                      { "creator_name_type" => "Personal", "creator_given_name" => "Lidai", "creator_family_name" => "Wang", "creator_position" => 1 },
                      { "creator_name_type" => "Personal", "creator_given_name" => "Chiye", "creator_family_name" => "Li", "creator_position" => 2 },
                      { "creator_name_type" => "Personal", "creator_given_name" => "Yan", "creator_family_name" => "Liu", "creator_position" => 3 },
                      { "creator_name_type" => "Personal", "creator_given_name" => "Haixin", "creator_family_name" => "Ke", "creator_position" => 4 },
                      { "creator_name_type" => "Personal", "creator_given_name" => "Chi", "creator_family_name" => "Zhang", "creator_position" => 5 },
                      { "creator_name_type" => "Personal", "creator_given_name" => "Lihong V.", "creator_family_name" => "Wang", "creator_position" => 6 }],
            resource_type: ["Other"],
            visibility: "restricted",
            autopopulation_status: "draft"
          }
        end

        let(:crossref_types) do
          {
            types: [%w[resourceType journalArticle]]
          }
        end

        let(:crossref_response) { File.read(Hyrax::Autopopulation::Engine.root.join("spec", "fixtures", "crossref_10.1117_12.2004063.json")) }

        let(:metadata_class) do
          Class.new(Bolognese::Metadata) do
            include Bolognese::Writers::HyraxWorkActorAttributes
          end
        end

        let(:metadata) { metadata_class.new(input: crossref_response) }
        let(:transformed_data) { metadata.build_work_actor_attributes }
        let(:crossref_types_data) { metadata.build_crossref_types }

        it "returns :title in format needed by JSonFieldsActors" do
          expect(transformed_data[:title]).to eq attributes[:title]
        end

        it "returns :creators in format needed JSonFieldsActors" do
          expect(transformed_data[:creator]).to eq attributes[:creator]
        end

        it "returns :date_published in format needed JSonFieldsActors" do
          expect(transformed_data[:date_published]).to eq attributes[:date_published]
        end

        it "returns :autopopulation_status in format needed JSonFieldsActors" do
          expect(transformed_data[:autopopulation_status]).to eq attributes[:autopopulation_status]
        end

        it "returns :types in format needed by JSonFieldsActors" do
          expect(transformed_data[:types]).to eq attributes[:types]
        end
      end
    end
  end
end
# rubocop:enable RSpec/DescribeClass
