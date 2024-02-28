# frozen_string_literal: true

class OkcChaptersAndBookSectionIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:okc_chapters_and_book_section)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
