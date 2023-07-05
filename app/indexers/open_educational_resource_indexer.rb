# frozen_string_literal: true

class OpenEducationalResourceIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:open_educational_resource)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end