# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverThesisDissertationCapstone`
class DenverThesisDissertationCapstone < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::DOI::DOIBehavior
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase

  property :table_of_contents, predicate: ::RDF::Vocab::Bibframe.term(:tableOfContents), multiple: false do |index|
    index.as :stored_searchable
  end

  property :extent, predicate: ::RDF::Vocab::DC.extent, multiple: false do |index|
    index.as :stored_searchable
  end

  property :medium, predicate: ::RDF::Vocab::DC.medium do |index|
    index.as :stored_searchable
  end

  property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
    index.as :stored_searchable, :facetable
  end

  property :degree, predicate: ::RDF::Vocab::SCHEMA.evidenceLevel, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :qualification_level, predicate: ::RDF::Vocab::BF2.degree, multiple: false do |index|
    index.as :stored_searchable
  end

  property :qualification_name, predicate: ::RDF::Vocab::SCHEMA.qualifications, multiple: false do |index|
    index.as :stored_searchable
  end

  property :advisor, predicate: ::RDF::Vocab::Bibframe.Person do |index|
    index.as :stored_searchable
  end

  property :committee_member, predicate: ::RDF::Vocab::AS.term(:Person) do |index|
    index.as :stored_searchable
  end

  property :pagination, predicate: ::RDF::Vocab::BIBO.numPages, multiple: false do |index|
    index.as :stored_searchable
  end

  property :references, predicate: ::RDF::Vocab::DC.references do |index|
    index.as :stored_searchable
  end

  self.indexer = DenverThesisDissertationCapstoneIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
