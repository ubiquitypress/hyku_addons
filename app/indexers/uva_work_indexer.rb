# frozen_string_literal: true

class UvaWorkIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:uva_work)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
