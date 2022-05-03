# frozen_string_literal: true
class UnaArchivalItem < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:una_archival_item)
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include Hyrax::BasicMetadata

  self.indexer = UnaArchivalItemIndexer

  validates :title, presence: { message: "Your work must have a title." }

  # Ensures old data will not return active_triples in edit forms
  # since the old data  existed before the forms was changed to
  # accetpt single value for aray or multi-value fields
  ARRAYTURNEDSINGLEFIELD = %i[
    duration is_format_of language license rights_holder event_title event_date
    event_location library_of_congress_classification related_exhibition_date
    related_exhibition_venue related_exhibition_date related_exhibition
    related_url source publisher place_of_publication citation subject
  ].freeze

  include HykuAddons::ArrayFieldToSingleField
  override_array_field_accessor(*ARRAYTURNEDSINGLEFIELD)

  def doi_registrar_opts
    {}
  end
end
