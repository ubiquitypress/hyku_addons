# frozen_string_literal: true

class LtuTimeBasedMediaIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ltu_time_based_media)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
