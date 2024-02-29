# frozen_string_literal: true

class OkcTimeBasedMediaIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:okc_time_based_media)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
