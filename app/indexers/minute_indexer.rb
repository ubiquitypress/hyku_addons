# frozen_string_literal: true

class MinuteIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:minute)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
