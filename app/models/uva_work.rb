# frozen_string_literal: true

class UvaWork < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DOIBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:uva_work)

  self.indexer = UbiquityTemplateWorkIndexer

  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  include ::Hyrax::BasicMetadata
end
