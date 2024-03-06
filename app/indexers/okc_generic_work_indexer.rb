# frozen_string_literal: true
class OkcGenericWorkIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:okc_generic_work)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
