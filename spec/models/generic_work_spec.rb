# frozen_string_literal: true

require "spec_helper"
require "hyrax/doi/spec/shared_specs"

RSpec.describe GenericWork do
  let(:work) { described_class.new }
  let(:fully_described_work) { build(:fully_described_work) }

  it_behaves_like "a DOI-enabled model"
  it_behaves_like "a DataCite DOI-enabled model"

  describe "additional properties" do
    let(:additional_properties) do
      [
        :volume, :pagination, :issn, :eissn, :official_link, :series_name, :edition,
        :event_title, :event_date, :event_location, :book_title, :journal_title,
        :issue, :article_num, :isbn, :media, :related_exhibition, :related_exhibition_date,
        :version, :version_number, :alternative_journal_title, :related_exhibition_venue,
        :current_he_institution, :qualification_name, :qualification_level, :duration, :editor,
        :institution, :org_unit, :refereed, :funder, :fndr_project_ref, :add_info, :date_published,
        :date_accepted, :date_submitted, :project_name, :rights_holder, :place_of_publication,
        :abstract, :alternate_identifier, :related_identifier, :library_of_congress_classification,
        :alt_title, :dewey
      ]
    end

    let(:additional_property_index_keys) do
      [
        :volume_tesim, :pagination_tesim, :issn_tesim, :eissn_tesim, :official_link_tesim,
        :series_name_tesim, :series_name_sim, :edition_tesim, :event_title_tesim, :event_title_sim,
        :event_date_tesim, :event_location_tesim, :book_title_tesim, :book_title_sim,
        :journal_title_tesim, :journal_title_sim, :issue_tesim, :article_num_tesim, :isbn_tesim,
        :media_tesim, :related_exhibition_tesim, :related_exhibition_date_tesim, :version_tesim,
        :version_number_tesim, :alternative_journal_title_tesim, :related_exhibition_venue_tesim,
        :current_he_institution_tesim, :qualification_name_tesim, :qualification_level_tesim,
        :duration_tesim, :editor_tesim, :institution_tesim, :institution_sim, :org_unit_tesim,
        :refereed_tesim, :funder_tesim, :fndr_project_ref_tesim, :add_info_tesim, :date_published_tesim,
        :date_accepted_tesim, :date_submitted_tesim, :project_name_tesim, :rights_holder_tesim,
        :place_of_publication_tesim, :place_of_publication_sim, :abstract_tesim, :alternate_identifier_tesim,
        :related_identifier_tesim, :library_of_congress_classification_tesim, :library_of_congress_classification_sim,
        :alt_title_tesim, :dewey_tesim
      ]
    end

    it "defines additional property accessors" do
      additional_properties.each { |property| expect(work.respond_to?(property)).to eq true }
    end

    it "defines additional property writers" do
      additional_properties.each { |property| expect(work.respond_to?("#{property}=".to_sym)).to eq true }
    end

    it "indexes additional properties" do
      expect(fully_described_work.to_solr.symbolize_keys.keys).to include(*additional_property_index_keys)
    end

    it "implements orcid_put_code" do
      expect(work).to respond_to(:orcid_put_code)
    end
  end
end
