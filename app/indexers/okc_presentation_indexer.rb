# frozen_string_literal: true

class OkcPresentationIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:okc_presentation)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
