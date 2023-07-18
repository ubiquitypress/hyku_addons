# frozen_string_literal: true
class ArchivalMaterial < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:archival_material)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = ::ArchivalMaterialIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
