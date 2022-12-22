# frozen_string_literal: true
class EslnDataset < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:esln_dataset)
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include Hyrax::BasicMetadata

  self.indexer = EslnDatasetIndexer

  validates :title, presence: { message: "Your work must have a title." }

  def doi_registrar_opts
    {}
  end
end
