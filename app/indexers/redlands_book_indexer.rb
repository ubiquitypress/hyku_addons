# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsBook`
class RedlandsBookIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:redlands_book)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
