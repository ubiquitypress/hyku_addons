# frozen_string_literal: true

class BcBookIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:bc_book)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
