# frozen_string_literal: true
class UnaThesisOrDissertation < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  # Adds behaviors for hyrax-doi plugin.
  include Hyrax::DOI::DOIBehavior
  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase
  include ::HykuAddons::AddInfoSingular

  property :additional_links, predicate: ::RDF::Vocab::SCHEMA.significantLinks, multiple: false do |index|
    index.as :stored_searchable
  end

  property :degree, predicate: ::RDF::Vocab::SCHEMA.evidenceLevel, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :location, predicate: ::RDF::Vocab::BF2.physicalLocation, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :qualification_grantor, predicate: ::RDF::Vocab::BF2.grantingInstitution, multiple: false do |index|
    index.as :stored_searchable
  end

  property :qualification_name, predicate: ::RDF::Vocab::SCHEMA.qualifications, multiple: false do |index|
    index.as :stored_searchable
  end

  property :qualification_level, predicate: ::RDF::Vocab::BF2.degree, multiple: false do |index|
    index.as :stored_searchable
  end

  property :alt_email, predicate: ::RDF::Vocab::SCHEMA.email do |index|
    index.as :stored_searchable
  end

  property :committee_member, predicate: ::RDF::Vocab::AS.term(:Person) do |index|
    index.as :stored_searchable
  end

  property :advisor, predicate: ::RDF::Vocab::Bibframe.Person, multiple: false do |index|
    index.as :stored_searchable
  end

  property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
    index.as :stored_searchable, :facetable
  end

  property :citation, predicate: ::RDF::Vocab::DC.term(:bibliographicCitation) do |index|
    index.as :stored_searchable
  end

  property :rights_statement_text, predicate: ::RDF::Vocab::DC11.rights, multiple: false do |index|
    index.as :stored_searchable
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

  self.indexer = UnaThesisOrDissertationIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
