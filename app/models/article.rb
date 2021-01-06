# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work Article`
class Article < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  # Adds behaviors for hyrax-doi plugin.
  include Hyrax::DOI::DOIBehavior
  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase

  property :journal_title, predicate: ::RDF::Vocab::BIBO.Journal, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :alternative_journal_title, predicate: ::RDF::Vocab::SCHEMA.alternativeHeadline, multiple: true do |index|
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

  property :article_num, predicate: ::RDF::Vocab::BIBO.number, multiple: false do |index|
    index.as :stored_searchable
  end

  property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
    index.as :stored_searchable, :facetable
  end

  property :issn, predicate: ::RDF::Vocab::BIBO.issn, multiple: false do |index|
    index.as :stored_searchable
  end

  property :eissn, predicate: ::RDF::Vocab::BIBO.eissn, multiple: false do |index|
    index.as :stored_searchable
  end

  property :refereed, predicate: ::RDF::Vocab::BIBO.term("status/peerReviewed"), multiple: false do |index|
    index.as :stored_searchable
  end

  self.indexer = HykuAddons::ArticleIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
