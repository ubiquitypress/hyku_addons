# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverMultimedia`
class DenverMultimedia < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::DOI::DOIBehavior
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase
  include ::HykuAddons::AltTitleMultiple
  include ::HykuAddons::AddInfoSingular

  property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
    index.as :stored_searchable, :facetable
  end

  property :event_title, predicate: ::RDF::Vocab::BF2.term(:Event) do |index|
    index.as :stored_searchable, :facetable
  end

  property :event_location, predicate: ::RDF::Vocab::Bibframe.eventPlace do |index|
    index.as :stored_searchable
  end

  property :medium, predicate: ::RDF::Vocab::DC.medium do |index|
    index.as :stored_searchable
  end

  property :duration, predicate: ::RDF::Vocab::BF2.duration, multiple: true do |index|
    index.as :stored_searchable
  end

  self.indexer = DenverMultimediaIndexer

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
