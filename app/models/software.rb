# frozen_string_literal: true

class Software < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:software)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = SoftwareIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
