# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work PacificImage`
class PacificImage < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:pacific_image)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = PacificImageIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
