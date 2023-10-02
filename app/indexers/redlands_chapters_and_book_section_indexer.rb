# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsChaptersAndBookSection`
class RedlandsChaptersAndBookSectionIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:redlands_chapters_and_book_section)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
