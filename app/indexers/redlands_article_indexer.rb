# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsArticle`
class RedlandsArticleIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:redlands_article)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
