# frozen_string_literal: true

class OkcImageIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:okc_image)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
