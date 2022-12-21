# frozen_string_literal: true

class LacBookIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:lac_book)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
