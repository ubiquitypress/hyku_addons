# frozen_string_literal: true

class Dataset < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:dataset)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = ::DatasetIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
