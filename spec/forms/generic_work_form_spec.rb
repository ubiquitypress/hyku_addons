# frozen_string_literal: true

require "spec_helper"
require "hyrax/doi/spec/shared_specs"

RSpec.describe Hyrax::GenericWorkForm do
  let(:work) { GenericWork.new }
  let(:form) { described_class.new(work, nil, nil) }

  it_behaves_like "a DOI-enabled form"
  it_behaves_like "a DataCite DOI-enabled form"

  describe ".required_fields" do
    subject { form.required_fields }

    it { is_expected.to eq %i[title resource_type creator institution date_published] }
  end

  describe "#terms" do
    subject { form.terms }

    it do
      expected_terms = %i[title resource_type creator alt_title contributor rendering_ids abstract date_published media
                          duration institution org_unit project_name funder fndr_project_ref event_title event_location
                          event_date series_name book_title editor journal_title alternative_journal_title volume edition
                          version_number issue pagination article_num publisher place_of_publication isbn issn eissn
                          current_he_institution date_accepted date_submitted official_link related_url related_exhibition
                          related_exhibition_venue related_exhibition_date language license rights_statement rights_holder
                          doi qualification_name qualification_level alternate_identifier related_identifier refereed
                          keyword dewey library_of_congress_classification add_info representative_id thumbnail_id]
      is_expected.to include(*expected_terms)
    end
  end

  describe ".secondary_terms" do
    subject { form.secondary_terms }

    it do
      is_expected.not_to include(:title, :creator,
                                 :visibilty, :visibility_during_embargo,
                                 :embargo_release_date, :visibility_after_embargo,
                                 :visibility_during_lease, :lease_expiration_date,
                                 :visibility_after_lease)
    end
  end

  describe ".model_attributes" do
    subject(:model_attributes) { described_class.model_attributes(params) }

    let(:params) { ActionController::Parameters.new(attributes) }
    let(:attributes) do
      {
        title: ["foo"],
        rendering_ids: ["file-set-id"],
        abstract: "abstract"
      }
    end

    it "permits parameters" do
      expect(model_attributes["title"]).to eq ["foo"]
      expect(model_attributes["rendering_ids"]).to eq ["file-set-id"]
      expect(model_attributes["abstract"]).to eq "abstract"
    end

    context ".model_attributes" do
      let(:params) do
        ActionController::Parameters.new(
          title: [""],
          abstract: "",
          keyword: [""],
          license: [""],
          on_behalf_of: "Melissa"
        )
      end

      it "removes blank parameters" do
        expect(model_attributes["title"]).to be_empty
        expect(model_attributes["abstract"]).to be_nil
        expect(model_attributes["license"]).to be_empty
        expect(model_attributes["keyword"]).to be_empty
        expect(model_attributes["on_behalf_of"]).to eq "Melissa"
      end
    end
  end
end
