# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverThesisDissertationCapstone`
class DenverThesisDissertationCapstone < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:denver_thesis_dissertation_capstone)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = DenverThesisDissertationCapstoneIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
