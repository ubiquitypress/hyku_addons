# frozen_string_literal: true

class UbiquityTemplateWork < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DOIBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:ubiquity_template_work)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = UbiquityTemplateWorkIndexer

  validates :title, presence: { message: 'Your work must have a title.' }
end
