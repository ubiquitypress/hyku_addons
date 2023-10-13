# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificMedia`
class PacificMedia < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:pacific_media)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = PacificMediaIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
