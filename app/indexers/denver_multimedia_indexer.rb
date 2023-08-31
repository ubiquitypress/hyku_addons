# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverMultimedia`
class DenverMultimediaIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:denver_multimedia)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
