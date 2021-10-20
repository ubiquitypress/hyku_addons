# frozen_string_literal: true
class UnaTimeBasedMedia < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::DOI::DOIBehavior
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase
  include ::HykuAddons::AddInfoSingular

  property :duration, predicate: ::RDF::Vocab::BF2.duration, multiple: true do |index|
    index.as :stored_searchable
  end

  property :event_title, predicate: ::RDF::Vocab::BF2.term(:Event) do |index|
    index.as :stored_searchable, :facetable
  end

  property :event_location, predicate: ::RDF::Vocab::Bibframe.eventPlace do |index|
    index.as :stored_searchable
  end

  property :event_date, predicate: ::RDF::Vocab::Bibframe.eventDate do |index|
    index.as :stored_searchable
  end

  property :related_exhibition, predicate: ::RDF::Vocab::SCHEMA.term(:ExhibitionEvent) do |index|
    index.as :stored_searchable
  end

  property :related_exhibition_venue, predicate: ::RDF::Vocab::SCHEMA.EventVenue, multiple: true do |index|
    index.as :stored_searchable
  end

  property :related_exhibition_date, predicate: ::RDF::Vocab::SCHEMA.term(:Date) do |index|
    index.as :stored_searchable
  end

  property :rights_statement_text, predicate: ::RDF::Vocab::DC11.rights, multiple: false do |index|
    index.as :stored_searchable
  end

  property :alt_email, predicate: ::RDF::Vocab::SCHEMA.email do |index|
    index.as :stored_searchable
  end

  property :additional_links, predicate: ::RDF::Vocab::SCHEMA.significantLinks, multiple: false do |index|
    index.as :stored_searchable
  end

  property :irb_status, predicate: ::RDF::Vocab::BF2.Status, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :irb_number, predicate: ::RDF::Vocab::BIBO.identifier, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :related_material, predicate: ::RDF::Vocab::BF2.term(:relatedTo), multiple: false do |index|
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

  property :georeferenced, predicate: ::RDF::Vocab::OGC.boolean_str, multiple: false do |index|
    index.as :stored_searchable
  end

  property :time, predicate: ::RDF::Vocab::DC.temporal, multiple: false do |index|
    index.as :stored_searchable
  end

  self.date_fields += %i[event_date related_exhibition_date]

  self.indexer = UnaTimeBasedMediaIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
