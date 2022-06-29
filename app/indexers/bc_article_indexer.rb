# frozen_string_literal: true

class BcArticleIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:bc_article)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
