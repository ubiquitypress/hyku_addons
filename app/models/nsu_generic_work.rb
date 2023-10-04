# frozen_string_literal: true

class NsuGenericWork < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:nsu_generic_work)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = NsuGenericWorkIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
