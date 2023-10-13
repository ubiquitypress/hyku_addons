# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificTextWork`
class PacificTextWorkIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:pacific_text_work)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
  # end
end
