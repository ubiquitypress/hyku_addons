# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work TimeBasedMedia`
class TimeBasedMedia < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:time_based_media)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = ::TimeBasedMediaIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
