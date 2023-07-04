# frozen_string_literal: true

class SoftwareIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:software)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end