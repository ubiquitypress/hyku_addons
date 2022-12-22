# frozen_string_literal: true

class EslnThesisDissertationIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:esln_thesis_dissertation)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
