# frozen_string_literal: true
class BcArchivalMaterial < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:bc_archival_material)
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include Hyrax::BasicMetadata

  self.indexer = BcArchivalMaterialIndexer

  validates :title, presence: { message: "Your work must have a title." }
end