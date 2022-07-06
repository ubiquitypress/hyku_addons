# frozen_string_literal: true
class BcPresentation < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior
  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:bc_presentation)
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include Hyrax::BasicMetadata

  self.indexer = BcPresentationIndexer

  validates :title, presence: { message: "Your work must have a title." }

  def doi_registrar_opts
    {}
  end
end
