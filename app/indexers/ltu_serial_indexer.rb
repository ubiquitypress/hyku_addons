# frozen_string_literal: true

class LtuSerialIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ltu_serial)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
