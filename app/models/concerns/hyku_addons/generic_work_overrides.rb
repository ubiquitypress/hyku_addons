# frozen_string_literal: true

module HykuAddons
  module GenericWorkOverrides
    extend ActiveSupport::Concern

    include ::HykuAddons::WorkBase

    # TODO: Review indexing and switch to mostly _ssim instead of _tesim
    included do
      # Adds behaviors for hyrax-doi plugin.
      include Hyrax::DOI::DOIBehavior
      # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
      include Hyrax::DOI::DataCiteDOIBehavior

      # From SharedMetadata
      property :volume, predicate: ::RDF::Vocab::BIBO.volume do |index|
        index.as :stored_searchable
      end

      property :pagination, predicate: ::RDF::Vocab::BIBO.numPages, multiple: false do |index|
        index.as :stored_searchable
      end

      property :issn, predicate: ::RDF::Vocab::BIBO.issn, multiple: false do |index|
        index.as :stored_searchable
      end

      property :eissn, predicate: ::RDF::Vocab::BIBO.eissn, multiple: false do |index|
        index.as :stored_searchable
      end

      property :series_name, predicate: ::RDF::Vocab::BF2.subseriesOf do |index|
        index.as :stored_searchable, :facetable
      end

      property :edition, predicate: ::RDF::Vocab::BF2.edition, multiple: false do |index|
        index.as :stored_searchable
      end

      property :event_title, predicate: ::RDF::Vocab::BF2.term(:Event) do |index|
        index.as :stored_searchable, :facetable
      end

      property :event_date, predicate: ::RDF::Vocab::Bibframe.eventDate do |index|
        index.as :stored_searchable
      end

      property :event_location, predicate: ::RDF::Vocab::Bibframe.eventPlace do |index|
        index.as :stored_searchable
      end

      property :book_title, predicate: ::RDF::Vocab::BIBO.term(:Proceedings), multiple: false do |index|
        index.as :stored_searchable, :facetable
      end

      property :journal_title, predicate: ::RDF::Vocab::BIBO.Journal, multiple: false do |index|
        index.as :stored_searchable, :facetable
      end

      property :issue, predicate: ::RDF::Vocab::Bibframe.term(:Serial), multiple: false do |index|
        index.as :stored_searchable
      end

      property :article_num, predicate: ::RDF::Vocab::BIBO.number, multiple: false do |index|
        index.as :stored_searchable
      end

      property :isbn, predicate: ::RDF::Vocab::BIBO.isbn, multiple: false do |index|
        index.as :stored_searchable
      end

      property :media, predicate: ::RDF::Vocab::MODS.physicalForm do |index|
        index.as :stored_searchable
      end

      property :related_exhibition, predicate: ::RDF::Vocab::SCHEMA.term(:ExhibitionEvent) do |index|
        index.as :stored_searchable
      end

      property :related_exhibition_date, predicate: ::RDF::Vocab::SCHEMA.term(:Date) do |index|
        index.as :stored_searchable
      end

      property :version, predicate: ::RDF::Vocab::SCHEMA.version do |index|
        index.as :stored_searchable
      end

      property :version_number, predicate: ::RDF::Vocab::SCHEMA.version do |index|
        index.as :stored_searchable
      end

      property :alternative_journal_title, predicate: ::RDF::Vocab::SCHEMA.alternativeHeadline, multiple: true do |index|
        index.as :stored_searchable
      end

      property :related_exhibition_venue, predicate: ::RDF::Vocab::SCHEMA.EventVenue, multiple: true do |index|
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

      property :duration, predicate: ::RDF::Vocab::BF2.duration, multiple: true do |index|
        index.as :stored_searchable
      end

      property :editor, predicate: ::RDF::Vocab::SCHEMA.Person do |index|
        index.as :stored_searchable
      end

      # From BasicMetadataDecorator
      property :refereed, predicate: ::RDF::Vocab::BIBO.term("status/peerReviewed"), multiple: false do |index|
        index.as :stored_searchable
      end

      property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
        index.as :stored_searchable, :facetable
      end

      self.json_fields += %i[editor current_he_institution]
      self.date_fields += %i[event_date related_exhibition_date]
    end
  end
end
