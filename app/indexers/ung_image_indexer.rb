# frozen_string_literal: true

class UngImageIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ung_image)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
