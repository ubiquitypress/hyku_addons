# frozen_string_literal: true
class PresentationIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:presentation)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
