# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificPresentation`
class PacificPresentation < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:pacific_presentation)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = PacificPresentationIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
