# frozen_string_literal: true

class UngBookIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ung_book)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
