# frozen_string_literal: true

class GrantRecord < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:grant_record)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = GrantRecordIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end