# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificThesisOrDissertation`
class PacificThesisOrDissertationIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:pacific_thesis_or_dissertation)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
