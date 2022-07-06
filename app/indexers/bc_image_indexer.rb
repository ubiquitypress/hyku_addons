# frozen_string_literal: true

class BcImageIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:bc_image)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
