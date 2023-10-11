# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificArticle`
class PacificArticleIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:pacific_article)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
