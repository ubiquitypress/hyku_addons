# frozen_string_literal: true

class BcTimeBasedMediaIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:bc_time_based_media)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
