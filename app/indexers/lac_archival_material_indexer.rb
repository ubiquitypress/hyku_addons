# frozen_string_literal: true

class LacArchivalMaterialIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:lac_archival_material)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
