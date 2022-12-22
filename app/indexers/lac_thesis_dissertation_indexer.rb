# frozen_string_literal: true

class LacThesisDissertationIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:lac_thesis_dissertation)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
