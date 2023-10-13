# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificUncategorized`
class PacificUncategorized < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:pacific_uncategorized)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = PacificUncategorizedIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
