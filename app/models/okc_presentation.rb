# frozen_string_literal: true
class OkcPresentation < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior
  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:okc_presentation)
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include Hyrax::BasicMetadata

  self.indexer = OkcPresentationIndexer

  validates :title, presence: { message: "Your work must have a title." }

  def doi_registrar_opts
    {}
  end
end
