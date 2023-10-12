# frozen_string_literal: true

class PacificBook < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:pacific_book)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = PacificBookIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
