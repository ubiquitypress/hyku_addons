# frozen_string_literal: true

require "spec_helper"
require "hyrax/doi/spec/shared_specs"

RSpec.describe SolrDocument, type: :model do
  let(:document) { described_class.new }
  let(:additional_properties) do
    [
      :volume, :pagination, :issn, :eissn, :official_link, :series_name, :edition,
      :event_title, :event_date, :event_location, :book_title, :journal_title,
      :issue, :article_num, :isbn, :media, :related_exhibition, :related_exhibition_date,
      :version, :version_number, :alternative_journal_title, :related_exhibition_venue,
      :current_he_institution, :qualification_name, :qualification_level, :duration, :editor,
      :institution, :org_unit, :refereed, :funder, :fndr_project_ref, :add_info, :date_published,
      :date_accepted, :date_submitted, :project_name, :rights_holder, :place_of_publication,
      :abstract, :alternate_identifier, :related_identifier, :creator, :contributor,
      :library_of_congress_classification, :alt_title, :dewey,
      :creator_display, :contributor_display, :editor_display
    ]
  end

  let(:solr_document_class) { described_class }
  it_behaves_like "a DOI-enabled solr document"
  it_behaves_like "a DataCite DOI-enabled solr document"

  describe "accessors" do
    it "defines accessors" do
      additional_properties.each { |property| expect(document).to respond_to(property) }
    end
  end
end
