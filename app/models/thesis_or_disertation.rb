# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work ThesisOrDisertation`
class ThesisOrDisertation < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::DOI::DOIBehavior
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase

  self.indexer = ThesisOrDisertationIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
    index.as :stored_searchable, :facetable
  end

  property :related_exhibition_date, predicate: ::RDF::Vocab::SCHEMA.term(:Date) do |index|
    index.as :stored_searchable
  end

  self.date_fields += %i[date_published]

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
