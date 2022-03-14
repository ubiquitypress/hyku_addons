# frozen_string_literal: true

class AnschutzWorkIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:anschutz_work)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
