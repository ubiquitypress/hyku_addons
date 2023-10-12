# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificMedia`
class PacificMediaIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:pacific_media)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
