# frozen_string_literal: true

class UnaBook < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::DOI::DOIBehavior
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase
  include ::HykuAddons::AddInfoSingular

  property :alt_title, predicate: ::RDF::Vocab::DC.alternative, multiple: false do |index|
    index.as :stored_searchable
  end

  property :buy_book, predicate: ::RDF::Vocab::SCHEMA.BuyAction, multiple: false do |index|
    index.as :stored_searchable
  end

  property :isbn, predicate: ::RDF::Vocab::BIBO.isbn, multiple: false do |index|
    index.as :stored_searchable
  end

  property :alt_email, predicate: ::RDF::Vocab::SCHEMA.email do |index|
    index.as :stored_searchable
  end

  property :version_number, predicate: ::RDF::Vocab::SCHEMA.version do |index|
    index.as :stored_searchable
  end

  property :table_of_contents, predicate: ::RDF::Vocab::Bibframe.term(:tableOfContents), multiple: false do |index|
    index.as :stored_searchable
  end

  property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
    index.as :stored_searchable, :facetable
  end

  property :edition, predicate: ::RDF::Vocab::BF2.edition, multiple: false do |index|
    index.as :stored_searchable
  end

  property :series_name, predicate: ::RDF::Vocab::BF2.subseriesOf do |index|
    index.as :stored_searchable, :facetable
  end

  property :longitude, predicate: ::RDF::Vocab::SCHEMA.longitude, multiple: false do |index|
    index.as :stored_searchable
  end

  property :location, predicate: ::RDF::Vocab::BF2.physicalLocation, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :latitude, predicate: ::RDF::Vocab::SCHEMA.latitude, multiple: false do |index|
    index.as :stored_searchable
  end

  self.indexer = UnaBookIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: "Your work must have a title." }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
