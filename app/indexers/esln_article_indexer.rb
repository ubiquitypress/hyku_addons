# frozen_string_literal: true

class EslnArticleIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:esln_article)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
