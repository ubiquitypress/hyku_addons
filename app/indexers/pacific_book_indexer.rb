# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificBook`
class PacificBookIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:pacific_book)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
