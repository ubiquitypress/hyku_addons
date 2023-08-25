# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverBookChapter`
class DenverBookChapterIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:denver_book_chapter)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
