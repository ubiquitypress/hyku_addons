# frozen_string_literal: true
class Presentation < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:presentation)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = ::PresentationIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
