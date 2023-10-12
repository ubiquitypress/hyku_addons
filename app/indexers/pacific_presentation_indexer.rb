# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificPresentation`
class PacificPresentationIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:pacific_presentation)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
