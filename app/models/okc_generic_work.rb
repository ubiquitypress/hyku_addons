# frozen_string_literal: true

class OkcGenericWork < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:okc_generic_work)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = OkcGenericWorkIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
