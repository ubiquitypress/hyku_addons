# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsOpenEducationalResource`
class RedlandsOpenEducationalResourceIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:redlands_open_educational_resource)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
