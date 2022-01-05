# frozen_string_literal: true

class UvaWork < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DOIBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:uva_work)

  include ::Hyrax::BasicMetadata

  self.indexer = UbiquityTemplateWorkIndexer

  validates :title, presence: { message: 'Your work must have a title.' }
end
