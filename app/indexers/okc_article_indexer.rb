# frozen_string_literal: true

class OkcArticleIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:okc_article)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
