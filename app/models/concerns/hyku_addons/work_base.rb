# frozen_string_literal: true

module HykuAddons
  module WorkBase
    extend ActiveSupport::Concern

    include HykuAddons::TaskMaster::WorkBehavior

    # TODO: Review indexing and switch to mostly _ssim instead of _tesim
    included do
      # From SharedMetadata
      property :official_link, predicate: ::RDF::Vocab::SCHEMA.url, multiple: false do |index|
        index.as :stored_searchable
      end

      # From BasicMetadataDecorator
      property :institution, predicate: ::RDF::Vocab::ORG.organization do |index|
        index.as :stored_searchable, :facetable
      end

      property :org_unit, predicate: ::RDF::Vocab::ORG.OrganizationalUnit do |index|
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

      # FIXME: Dates should be indexed as dates or at least _ssim not _tesim
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

      property :library_of_congress_classification, predicate: ::RDF::Vocab::BF2.term(:ClassificationLcc) do |index|
        index.as :stored_searchable, :facetable
      end

      property :dewey, predicate: ::RDF::Vocab::SCHEMA.CategoryCode, multiple: false do |index|
        index.as :stored_searchable
      end

      property :note, predicate: ::RDF::Vocab::MODS.note, multiple: true do |index|
        index.as :stored_searchable
      end

      # property :file_availability, predicate: ::RDF::Vocab::SCHEMA.ItemAvailability do |index|
      #   index.as :stored_searchable, :facetable
      # end

      property :source_identifier, predicate: ::RDF::Vocab::PROV.wasDerivedFrom, multiple: false do |index|
        index.as :stored_searchable
      end

      class_attribute :json_fields, :date_fields
      self.json_fields = %i[creator contributor funder alternate_identifier related_identifier]
      self.date_fields = %i[date_published date_accepted date_submitted]
    end
  end
end
