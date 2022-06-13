# frozen_string_literal: true

class UngPresentationIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ung_presentation)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
