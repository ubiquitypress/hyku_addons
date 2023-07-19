# frozen_string_literal: true
class ArchivalMaterialIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:archival_material)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
