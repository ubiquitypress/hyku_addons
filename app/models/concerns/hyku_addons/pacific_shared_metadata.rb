# frozen_string_literal: true
module HykuAddons
  module PacificSharedMetadata
    extend ActiveSupport::Concern
    included do
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

      property :page_display_order_number, predicate: ::RDF::Vocab::SCHEMA.orderNumber, multiple: false do |index|
        index.as :stored_searchable
      end

      property :additional_links, predicate: ::RDF::Vocab::SCHEMA.significantLinks, multiple: false do |index|
        index.as :stored_searchable
      end

      property :irb_status, predicate: ::RDF::Vocab::BF2.Status, multiple: false do |index|
        index.as :stored_searchable, :facetable
      end

      property :irb_number, predicate: ::RDF::Vocab::BIBO.identifier, multiple: false do |index|
        index.as :stored_searchable, :facetable
      end

      property :is_included_in, predicate: ::RDF::Vocab::BF2.part, multiple: false do |index|
        index.as :stored_searchable
      end

      property :buy_book, predicate: ::RDF::Vocab::SCHEMA.BuyAction, multiple: true do |index|
        index.as :stored_searchable
      end

      property :isbn, predicate: ::RDF::Vocab::BIBO.isbn, multiple: false do |index|
        index.as :stored_searchable
      end
    end
  end
end
