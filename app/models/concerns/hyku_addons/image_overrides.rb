# frozen_string_literal: true

module HykuAddons
  module ImageOverrides
    extend ActiveSupport::Concern

    include ::HykuAddons::WorkBase

    included do
      include Hyrax::DOI::DOIBehavior
      include Hyrax::DOI::DataCiteDOIBehavior

      property :media, predicate: ::RDF::Vocab::MODS.physicalForm do |index|
        index.as :stored_searchable
      end

      property :related_exhibition, predicate: ::RDF::Vocab::SCHEMA.term(:ExhibitionEvent) do |index|
        index.as :stored_searchable
      end

      property :related_exhibition_date, predicate: ::RDF::Vocab::SCHEMA.term(:Date) do |index|
        index.as :stored_searchable
      end

      property :related_exhibition_venue, predicate: ::RDF::Vocab::SCHEMA.EventVenue, multiple: true do |index|
        index.as :stored_searchable
      end

      property :duration, predicate: ::RDF::Vocab::BF2.duration, multiple: true do |index|
        index.as :stored_searchable
      end

      property :refereed, predicate: ::RDF::Vocab::BIBO.term("status/peerReviewed"), multiple: false do |index|
        index.as :stored_searchable
      end

      property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
        index.as :stored_searchable, :facetable
      end

      self.date_fields += %i[related_exhibition_date]
    end
  end
end
