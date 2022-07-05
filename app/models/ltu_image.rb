# frozen_string_literal: true
class LtuImage < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:ltu_image)
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include Hyrax::BasicMetadata

  self.indexer = LtuImageIndexer

  validates :title, presence: { message: "Your work must have a title." }
end