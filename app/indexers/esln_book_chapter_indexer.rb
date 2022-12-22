# frozen_string_literal: true

class EslnBookChapterIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:esln_book_chapter)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
