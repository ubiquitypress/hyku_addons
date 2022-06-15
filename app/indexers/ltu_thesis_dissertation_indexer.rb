# frozen_string_literal: true

class LtuThesisDissertationIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ltu_thesis_dissertation)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
