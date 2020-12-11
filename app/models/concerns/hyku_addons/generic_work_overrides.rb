# frozen_string_literal: true

module HykuAddons
  module GenericWorkOverrides
    extend ActiveSupport::Concern

    included do
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

      property :official_link, predicate: ::RDF::Vocab::SCHEMA.url, multiple: false do |index|
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
      property :institution, predicate: ::RDF::Vocab::ORG.organization do |index|
        index.as :stored_searchable, :facetable
      end

      property :org_unit, predicate: ::RDF::Vocab::ORG.OrganizationalUnit do |index|
        index.as :stored_searchable
      end

      property :refereed, predicate: ::RDF::Vocab::BIBO.term("status/peerReviewed"), multiple: false do |index|
        index.as :stored_searchable
      end

      property :funder, predicate: ::RDF::Vocab::MARCRelators.fnd do |index|
        index.as :stored_searchable
      end

      property :fndr_project_ref, predicate: ::RDF::Vocab::BF2.awards do |index|
        index.as :stored_searchable
      end

      property :add_info, predicate: ::RDF::Vocab::BIBO.term(:Note), multiple: false do |index|
        index.as :stored_searchable
      end

      property :date_published, predicate: ::RDF::Vocab::DC.available, multiple: false do |index|
        index.as :stored_searchable
      end

      property :date_accepted, predicate: ::RDF::Vocab::DC.dateAccepted, multiple: false do |index|
        index.as :stored_searchable
      end

      property :date_submitted, predicate: ::RDF::Vocab::Bibframe.originDate, multiple: false do |index|
        index.as :stored_searchable
      end

      property :project_name, predicate: ::RDF::Vocab::BF2.term(:CollectiveTitle) do |index|
        index.as :stored_searchable
      end

      property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder do |index|
        index.as :stored_searchable
      end

      property :place_of_publication, predicate: ::RDF::Vocab::BF2.term(:Place) do |index|
        index.as :stored_searchable, :facetable
      end

      property :abstract, predicate: ::RDF::Vocab::DC.abstract, multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :alternate_identifier, predicate: ::RDF::Vocab::BF2.term(:Local) do |index|
        index.as :stored_searchable
      end

      property :related_identifier, predicate: ::RDF::Vocab::BF2.identifiedBy do |index|
        index.as :stored_searchable
      end

      property :creator_search, predicate: ::RDF::Vocab::SCHEMA.creator do |index|
        index.as :stored_searchable, :facetable
      end

      property :library_of_congress_classification, predicate: ::RDF::Vocab::BF2.term(:ClassificationLcc) do |index|
        index.as :stored_searchable, :facetable
      end

      property :alt_title, predicate: ::RDF::Vocab::DC.alternative, multiple: true do |index|
        index.as :stored_searchable
      end

      property :dewey, predicate: ::RDF::Vocab::SCHEMA.CategoryCode, multiple: false do |index|
        index.as :stored_searchable
      end

      # property :file_availability, predicate: ::RDF::Vocab::SCHEMA.ItemAvailability do |index|
      #   index.as :stored_searchable, :facetable
      # end

      property :collection_id, predicate: ::RDF::Vocab::BF2.identifies do |index|
        index.as :stored_searchable, :facetable
      end

      property :collection_names, predicate: ::RDF::Vocab::DC11.term(:collect) do |index|
        index.as :stored_searchable, :facetable
      end

      class_attribute :json_fields
      self.json_fields = %i[creator contributor]
    end
  end
end
