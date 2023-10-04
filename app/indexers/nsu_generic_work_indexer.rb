# frozen_string_literal: true
class NsuGenericWorkIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:nsu_generic_work)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
