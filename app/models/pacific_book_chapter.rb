# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificBookChapter`
class PacificBookChapter < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  # Adds behaviors for hyrax-doi plugin.
  include Hyrax::DOI::DOIBehavior
  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::WorkBase
  include ::HykuAddons::AltTitleMultiple

  property :book_title, predicate: ::RDF::Vocab::BIBO.term(:Proceedings), multiple: false do |index|
    index.as :stored_searchable, :facetable
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

  property :volume, predicate: ::RDF::Vocab::BIBO.volume do |index|
    index.as :stored_searchable
  end

  property :issn, predicate: ::RDF::Vocab::BIBO.issn, multiple: false do |index|
    index.as :stored_searchable
  end

  property :isbn, predicate: ::RDF::Vocab::BIBO.isbn, multiple: false do |index|
    index.as :stored_searchable
  end

  property :refereed, predicate: ::RDF::Vocab::BIBO.term("status/peerReviewed"), multiple: false do |index|
    index.as :stored_searchable
  end

  property :location, predicate: ::RDF::Vocab::BF2.physicalLocation, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :page_display_order_number, predicate: ::RDF::Vocab::SCHEMA.orderNumber, multiple: false do |index|
    index.as :stored_searchable
  end

  self.indexer = PacificBookChapterIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
