# frozen_string_literal: true

class LtuDatasetIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ltu_dataset)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
