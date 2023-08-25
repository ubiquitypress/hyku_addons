# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverArticle`
class DenverArticleIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:denver_article)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
