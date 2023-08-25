# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverMap`
class DenverMapIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:denver_map)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
