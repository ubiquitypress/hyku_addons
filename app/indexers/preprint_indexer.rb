# frozen_string_literal: true
class PreprintIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:preprint)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
