# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work AnschutzWork`
class AnschutzWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::DOI::DOIBehavior
  include Hyrax::DOI::DataCiteDOIBehavior
  # Copied in from WorkBase
  # Needs to be defined before schema is included
  class_attribute :json_fields, :date_fields
  self.json_fields = []
  self.date_fields = []
  include Hyrax::Schema(:anschutz_work)
  # include ::HykuAddons::WorkBase
  # include ::HykuAddons::AltTitleMultiple

  self.indexer = AnschutzWorkIndexer

  #  property :location, predicate: ::RDF::Vocab::BF2.physicalLocation, multiple: false do |index|
  #    index.as :stored_searchable, :facetable
  #  end
  #
  #  property :subject_text, predicate: ::RDF::Vocab::DC.subject, multiple: true do |index|
  #    index.as :stored_searchable
  #  end
  #
  #  property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
  #    index.as :stored_searchable, :facetable
  #  end
  #
  #  property :mesh, predicate: ::RDF::Vocab::DC.term(:MESH) do |index|
  #    index.as :stored_searchable
  #  end
  #
  #  property :source, predicate: ::RDF::Vocab::DC.source do |index|
  #    index.as :stored_searchable
  #  end
  #
  #  property :journal_frequency, predicate: ::RDF::Vocab::DC.term(:Frequency) do |index|
  #    index.as :stored_searchable
  #  end
  #
  #  property :funding_description, predicate: ::RDF::Vocab::MARCRelators.spn do |index|
  #    index.as :stored_searchable
  #  end
  #
  #  property :citation, predicate: ::RDF::Vocab::DC.term(:bibliographicCitation) do |index|
  #    index.as :stored_searchable
  #  end
  #
  #  property :table_of_contents, predicate: ::RDF::Vocab::Bibframe.term(:tableOfContents), multiple: false do |index|
  #    index.as :stored_searchable
  #  end
  #
  #  property :citation, predicate: ::RDF::Vocab::DC.references do |index|
  #    index.as :stored_searchable
  #  end
  #
  #  property :extent, predicate: ::RDF::Vocab::DC.extent do |index|
  #    index.as :stored_searchable
  #  end
  #
  #  property :medium, predicate: ::RDF::Vocab::DC.medium do |index|
  #    index.as :stored_searchable
  #  end

  self.indexer = AnschutzWorkIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
