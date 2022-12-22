# frozen_string_literal: true

class EslnBookIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:esln_book)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
