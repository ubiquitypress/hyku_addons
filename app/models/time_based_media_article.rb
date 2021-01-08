# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work TimeBasedMediaArticle`
class TimeBasedMediaArticle < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  # Adds behaviors for hyrax-doi plugin.
  include Hyrax::DOI::DOIBehavior
  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase

  property :media, predicate: ::RDF::Vocab::MODS.physicalForm do |index|
    index.as :stored_searchable
  end

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

  property :editor, predicate: ::RDF::Vocab::SCHEMA.Person do |index|
    index.as :stored_searchable
  end

  property :version, predicate: ::RDF::Vocab::SCHEMA.version do |index|
    index.as :stored_searchable
  end

  property :version_number, predicate: ::RDF::Vocab::SCHEMA.version do |index|
    index.as :stored_searchable
  end

  property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
    index.as :stored_searchable, :facetable
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

  property :refereed, predicate: ::RDF::Vocab::BIBO.term("status/peerReviewed"), multiple: false do |index|
    index.as :stored_searchable
  end

  self.json_fields += %i[editor]
  self.date_fields += %i[event_date related_exhibition_date]

  self.indexer = TimeBasedMediaArticleIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
