# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverImage`
class DenverDatasetIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:denver_dataset)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
