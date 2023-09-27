# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsOpenEducationalResource`
class RedlandsOpenEducationalResource < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:redlands_open_educational_resource)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = RedlandsOpenEducationalResourceIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
