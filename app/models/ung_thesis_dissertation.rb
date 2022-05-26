# frozen_string_literal: true
class UngThesisDissertation < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:ung_thesis_dissertation)
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include Hyrax::BasicMetadata

  self.indexer = UngThesisDissertationIndexer

  validates :title, presence: { message: "Your work must have a title." }
end
