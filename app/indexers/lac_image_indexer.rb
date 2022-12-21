# frozen_string_literal: true

class LacImageIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:lac_image)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
