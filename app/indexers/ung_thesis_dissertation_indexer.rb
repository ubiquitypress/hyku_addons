# frozen_string_literal: true

class UngThesisDissertationIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ung_thesis_dissertation)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
