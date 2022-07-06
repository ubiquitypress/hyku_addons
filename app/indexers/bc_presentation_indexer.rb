# frozen_string_literal: true

class BcPresentationIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:bc_presentation)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
