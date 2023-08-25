# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverMap`
class DenverMap < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:denver_map)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = DenverMapIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
