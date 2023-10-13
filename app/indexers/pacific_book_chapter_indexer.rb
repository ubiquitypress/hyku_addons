# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificBookChapter`
class PacificBookChapterIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:pacific_book_chapter)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
