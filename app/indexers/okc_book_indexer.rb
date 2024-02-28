# frozen_string_literal: true

class OkcBookIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:okc_book)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
