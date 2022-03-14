# frozen_string_literal: true

class AnschutzWork < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior
  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:anschutz_work)
  include Hyrax::BasicMetadata

  self.indexer = AnschutzWorkIndexer

  validates :title, presence: { message: "Your work must have a title." }
end
