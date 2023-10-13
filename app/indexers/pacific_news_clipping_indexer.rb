# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificNewsClipping`
class PacificNewsClippingIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:pacific_news_clipping)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
