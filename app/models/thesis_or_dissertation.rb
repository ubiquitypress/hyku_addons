# frozen_string_literal: true

class ThesisOrDissertation < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::DOI::DOIBehavior
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase
  include ::HykuAddons::AltTitleMultiple
  include ::HykuAddons::AddInfoSingular

  self.indexer = ThesisOrDissertationIndexer

  validates :title, presence: { message: 'Your work must have a title.' }

  property :version, predicate: ::RDF::Vocab::SCHEMA.version do |index|
    index.as :stored_searchable
  end

  property :version_number, predicate: ::RDF::Vocab::SCHEMA.version do |index|
    index.as :stored_searchable
  end

  property :pagination, predicate: ::RDF::Vocab::BIBO.numPages, multiple: false do |index|
    index.as :stored_searchable
  end

  property :refereed, predicate: ::RDF::Vocab::BIBO.term("status/peerReviewed"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :current_he_institution, predicate: ::RDF::Vocab::SCHEMA.EducationalOrganization, multiple: true do |index|
    index.as :stored_searchable
  end

  property :qualification_name, predicate: ::RDF::Vocab::SCHEMA.qualifications, multiple: false do |index|
    index.as :stored_searchable
  end

  property :qualification_level, predicate: ::RDF::Vocab::BF2.degree, multiple: false do |index|
    index.as :stored_searchable
  end

  self.json_fields += %i[current_he_institution]

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
