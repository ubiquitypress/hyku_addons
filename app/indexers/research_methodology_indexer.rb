# frozen_string_literal: true

class ResearchMethodologyIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:research_methodology)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end