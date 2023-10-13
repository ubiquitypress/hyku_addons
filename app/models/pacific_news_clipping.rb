# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificNewsClipping`
class PacificNewsClipping < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:pacific_news_clipping)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = PacificNewsClippingIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
