# frozen_string_literal: true

class ThesisOrDissertation < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:thesis_or_dissertation)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = ::ThesisOrDissertationIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
