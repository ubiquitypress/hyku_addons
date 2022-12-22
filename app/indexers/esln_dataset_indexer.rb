# frozen_string_literal: true

class EslnDatasetIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:esln_dataset)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
