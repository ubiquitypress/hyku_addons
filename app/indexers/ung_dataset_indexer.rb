# frozen_string_literal: true

class UngDatasetIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ung_dataset)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
