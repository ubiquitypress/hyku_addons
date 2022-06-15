# frozen_string_literal: true

class LtuImageIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ltu_image)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
