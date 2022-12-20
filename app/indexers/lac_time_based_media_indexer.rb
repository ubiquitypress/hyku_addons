# frozen_string_literal: true

class LacTimeBasedMediaIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:lac_time_based_media)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
