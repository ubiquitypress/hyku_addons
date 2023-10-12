# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificUncategorized`
class PacificUncategorizedIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:pacific_uncategorized)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
