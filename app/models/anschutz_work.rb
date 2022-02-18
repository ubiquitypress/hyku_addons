# frozen_string_literal: true

class AnschutzWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::DOI::DOIBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:anschutz_work)

  self.indexer = AnschutzWorkIndexer

  validates :title, presence: { message: "Your work must have a title." }
end
