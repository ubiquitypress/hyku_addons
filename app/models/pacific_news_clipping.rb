# Generated via
#  `rails generate hyrax:work PacificNewsClipping`
class PacificNewsClipping < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  # Adds behaviors for hyrax-doi plugin.
  include Hyrax::DOI::DOIBehavior
  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase

  property :reading_level, predicate: ::RDF::Vocab::SCHEMA.proficiencyLevel, multiple: false do |index|
    index.as :stored_searchable
  end

  property :challenged, predicate: ::RDF::Vocab::SCHEMA.quest, multiple: false do |index|
    index.as :stored_searchable
  end

  property :location, predicate: ::RDF::Vocab::BF2.physicalLocation , multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :outcome, predicate: ::RDF::Vocab::SCHEMA.resultComment, multiple: false do |index|
    index.as :stored_searchable
  end

  property :participant, predicate: ::RDF::Vocab::BF2.Person, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :photo_caption, predicate: ::RDF::Vocab::SCHEMA.caption, multiple: false do |index|
    index.as :stored_searchable
  end

  property :photo_description, predicate: ::RDF::Vocab::SCHEMA.photo, multiple: false do |index|
    index.as :stored_searchable
  end

  property :pagination, predicate: ::RDF::Vocab::BIBO.numPages, multiple: false do |index|
    index.as :stored_searchable
  end

  property :additional_links, predicate: ::RDF::Vocab::SCHEMA.significantLinks, multiple: false do |index|
    index.as :stored_searchable
  end

  property :is_included_in, predicate: ::RDF::Vocab::BF2.part, multiple: false do |index|
    index.as :stored_searchable
  end

  self.indexer = PacificNewsClippingIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
