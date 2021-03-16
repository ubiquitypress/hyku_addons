# frozen_string_literal: true

class Report < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::DOI::DOIBehavior
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase

  self.indexer = ReportIndexer
  validates :title, presence: { message: 'Your work must have a title.' }

  property :pagination, predicate: ::RDF::Vocab::BIBO.numPages, multiple: false do |index|
    index.as :stored_searchable
  end

  property :refereed, predicate: ::RDF::Vocab::BIBO.term("status/peerReviewed"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :isbn, predicate: ::RDF::Vocab::BIBO.isbn, multiple: false do |index|
    index.as :stored_searchable
  end

  property :issn, predicate: ::RDF::Vocab::BIBO.issn, multiple: false do |index|
    index.as :stored_searchable
  end

  property :eissn, predicate: ::RDF::Vocab::BIBO.eissn, multiple: false do |index|
    index.as :stored_searchable
  end

  property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
    index.as :stored_searchable, :facetable
  end

  property :edition, predicate: ::RDF::Vocab::BF2.edition, multiple: false do |index|
    index.as :stored_searchable
  end

  property :volume, predicate: ::RDF::Vocab::BIBO.volume, multiple: false do |index|
    index.as :stored_searchable
  end

  property :editor, predicate: ::RDF::Vocab::SCHEMA.Person do |index|
    index.as :stored_searchable
  end

  property :series_name, predicate: ::RDF::Vocab::BF2.subseriesOf do |index|
    index.as :stored_searchable, :facetable
  end

  self.json_fields += %i[editor]

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
