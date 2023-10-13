# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificImage`
class PacificImageIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:pacific_image)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
