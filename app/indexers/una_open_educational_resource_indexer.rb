# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work UnaOpenEducationalResource`
class UnaOpenEducationalResourceIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:una_open_educational_resource)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
