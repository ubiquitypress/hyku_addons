# frozen_string_literal: true

class LtuPresentationIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ltu_presentation)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
