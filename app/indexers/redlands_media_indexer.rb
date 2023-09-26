# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsMedia`
class RedlandsMediaIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:redlands_media)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
