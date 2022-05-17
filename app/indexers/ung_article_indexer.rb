# frozen_string_literal: true

class UngArticleIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ung_article)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
