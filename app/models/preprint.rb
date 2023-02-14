# frozen_string_literal: true
class Preprint < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:preprint)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = ::PreprintIndexer
end
