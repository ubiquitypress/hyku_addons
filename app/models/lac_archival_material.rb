# frozen_string_literal: true
class LacArchivalMaterial < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:lac_archival_material)
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include Hyrax::BasicMetadata

  self.indexer = LacArchivalMaterialIndexer

  validates :title, presence: { message: "Your work must have a title." }
end
