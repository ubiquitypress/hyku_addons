# frozen_string_literal: true

class LtuBookChapterIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ltu_book_chapter)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
