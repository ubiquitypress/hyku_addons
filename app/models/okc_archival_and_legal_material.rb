# frozen_string_literal: true
class OkcArchivalAndLegalMaterial < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:okc_archival_and_legal_material)
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include Hyrax::BasicMetadata

  self.indexer = OkcArchivalAndLegalMaterialIndexer

  validates :title, presence: { message: "Your work must have a title." }

  def doi_registrar_opts
    {}
  end
end
