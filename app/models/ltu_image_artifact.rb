# frozen_string_literal: true
class LtuImageArtifact < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:ltu_image_artifact)
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include Hyrax::BasicMetadata

  self.indexer = LtuImageArtifactIndexer

  validates :title, presence: { message: "Your work must have a title." }
end
