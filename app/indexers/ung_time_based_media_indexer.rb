# frozen_string_literal: true

class UngTimeBasedMediaIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ung_time_based_media)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
