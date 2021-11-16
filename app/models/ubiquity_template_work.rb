# frozen_string_literal: true

class UbiquityTemplateWork < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DOIBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:ubiquity_template_work)

  self.indexer = UbiquityTemplateWorkIndexer

  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata schema
  include Hyrax::BasicMetadata
end
