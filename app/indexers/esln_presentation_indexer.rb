# frozen_string_literal: true

class EslnPresentationIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:esln_presentation)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
