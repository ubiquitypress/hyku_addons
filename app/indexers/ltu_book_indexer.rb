# frozen_string_literal: true

class LtuBookIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ltu_book)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
