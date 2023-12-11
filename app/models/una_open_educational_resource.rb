# frozen_string_literal: true
class UnaOpenEducationalResource < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:una_open_educational_resource)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = UnaOpenEducationalResourceIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
