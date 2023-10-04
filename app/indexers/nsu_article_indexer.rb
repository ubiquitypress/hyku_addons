# frozen_string_literal: true
class NsuArticleIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:nsu_article)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
