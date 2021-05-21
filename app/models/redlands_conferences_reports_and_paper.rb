# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsConferencesReportsAndPaper`
class RedlandsConferencesReportsAndPaper < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  # Adds behaviors for hyrax-doi plugin.
  include Hyrax::DOI::DOIBehavior
  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase

  property :alt_title, predicate: ::RDF::Vocab::DC.alternative, multiple: false do |index|
    index.as :stored_searchable
  end

  property :alt_email, predicate: ::RDF::Vocab::SCHEMA.email do |index|
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

  property :event_location, predicate: ::RDF::Vocab::Bibframe.eventPlace do |index|
    index.as :stored_searchable
  end

  self.indexer = RedlandsConferencesReportsAndPaperIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
