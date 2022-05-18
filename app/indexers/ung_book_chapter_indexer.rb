# frozen_string_literal: true

class UngBookChapterIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ung_book_chapter)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
