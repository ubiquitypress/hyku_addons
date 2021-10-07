# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work UnaArticle`
class UnaArticle < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  # Adds behaviors for hyrax-doi plugin.
  include Hyrax::DOI::DOIBehavior
  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase
  include ::HykuAddons::AddInfoSingular

  property :article_num, predicate: ::RDF::Vocab::BIBO.number, multiple: false do |index|
    index.as :stored_searchable
  end

  property :version_number, predicate: ::RDF::Vocab::SCHEMA.version do |index|
    index.as :stored_searchable
  end

  property :additional_links, predicate: ::RDF::Vocab::SCHEMA.significantLinks, multiple: false do |index|
    index.as :stored_searchable
  end

  property :related_material, predicate: ::RDF::Vocab::BF2.term(:relatedTo), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :citation, predicate: ::RDF::Vocab::DC.term(:bibliographicCitation) do |index|
    index.as :stored_searchable
  end

  property :funding_description, predicate: ::RDF::Vocab::MARCRelators.spn do |index|
    index.as :stored_searchable
  end

  property :georeferenced, predicate: ::RDF::Vocab::OGC.boolean_str, multiple: false do |index|
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

  property :alt_email, predicate: ::RDF::Vocab::SCHEMA.email, multiple: true do |index|
    index.as :stored_searchable
  end

  property :volume, predicate: ::RDF::Vocab::BIBO.volume do |index|
    index.as :stored_searchable
  end

  property :issue, predicate: ::RDF::Vocab::Bibframe.term(:Serial), multiple: false do |index|
    index.as :stored_searchable
  end

  property :pagination, predicate: ::RDF::Vocab::BIBO.numPages, multiple: false do |index|
    index.as :stored_searchable
  end

  property :issn, predicate: ::RDF::Vocab::BIBO.issn, multiple: false do |index|
    index.as :stored_searchable
  end

  property :refereed, predicate: ::RDF::Vocab::BIBO.term("status/peerReviewed"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :irb_status, predicate: ::RDF::Vocab::BF2.Status, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :irb_number, predicate: ::RDF::Vocab::BIBO.identifier, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :adapted_from, predicate: ::RDF::Vocab::DC11.source, multiple: false do |index|
    index.as :stored_searchable
  end

  property :eissn, predicate: ::RDF::Vocab::BIBO.eissn, multiple: false do |index|
    index.as :stored_searchable
  end

  property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
    index.as :stored_searchable, :facetable
  end

  property :funder, predicate: ::RDF::Vocab::MARCRelators.fnd do |index|
    index.as :stored_searchable
  end

  property :date_accepted, predicate: ::RDF::Vocab::DC.dateAccepted, multiple: false do |index|
    index.as :stored_searchable
  end

  property :date_submitted, predicate: ::RDF::Vocab::Bibframe.originDate, multiple: false do |index|
    index.as :stored_searchable
  end

  property :time, predicate: ::RDF::Vocab::DC.temporal, multiple: false do|index|
    index.as :stored_searchable
  end

  property :journal_title, predicate: ::RDF::Vocab::BIBO.Journal, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :alternative_journal_title, predicate: ::RDF::Vocab::SCHEMA.alternativeHeadline, multiple: false do |index|
    index.as :stored_searchable
  end

  property :journal_frequency, predicate: ::RDF::Vocab::DC.term(:Frequency), multiple: false do |index|
    index.as :stored_searchable
  end

  self.indexer = UnaArticleIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
