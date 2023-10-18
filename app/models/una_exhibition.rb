# frozen_string_literal: true

class UnaExhibition < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:una_exhibition)
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include Hyrax::BasicMetadata

  self.indexer = UnaExhibitionIndexer

  validates :title, presence: { message: "Your work must have a title." }

  def doi_registrar_opts
    {}
  end
end
