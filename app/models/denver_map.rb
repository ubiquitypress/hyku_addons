# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverMap`
class DenverMap < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::DOI::DOIBehavior
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase
  include ::HykuAddons::AltTitleMultiple
  include ::HykuAddons::AddInfoSingular

  property :georeferenced, predicate: ::RDF::Vocab::OGC.boolean_str, multiple: false do |index|
    index.as :stored_searchable
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

  property :extent, predicate: ::RDF::Vocab::DC.extent, multiple: false do |index|
    index.as :stored_searchable
  end

  property :subject_text, predicate: ::RDF::Vocab::DC.subject, multiple: true do |index|
    index.as :stored_searchable
  end

  property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
    index.as :stored_searchable, :facetable
  end

  property :event_title, predicate: ::RDF::Vocab::BF2.term(:Event) do |index|
    index.as :stored_searchable, :facetable
  end

  property :event_location, predicate: ::RDF::Vocab::Bibframe.eventPlace do |index|
    index.as :stored_searchable
  end

  property :time, predicate: ::RDF::Vocab::DC.temporal, multiple: false do |index|
    index.as :stored_searchable
  end

  self.indexer = DenverMapIndexer

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
