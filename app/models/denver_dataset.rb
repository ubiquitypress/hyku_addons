# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverDataset`
class DenverDataset < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:denver_dataset)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = DenverDatasetIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
