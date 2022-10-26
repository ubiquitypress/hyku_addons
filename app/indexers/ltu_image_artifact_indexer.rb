# frozen_string_literal: true

class LtuImageArtifactIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ltu_image_artifact)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
