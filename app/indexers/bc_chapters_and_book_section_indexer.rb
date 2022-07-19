# frozen_string_literal: true

class BcChaptersAndBookSectionIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:bc_chapters_and_book_section)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
