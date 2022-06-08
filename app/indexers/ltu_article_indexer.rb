# frozen_string_literal: true

class LtuArticleIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ltu_article)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
