# frozen_string_literal: true

class GrantRecordIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:grant_record)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end