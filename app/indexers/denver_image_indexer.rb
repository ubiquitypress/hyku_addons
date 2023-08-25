# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverImage`
class DenverImageIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:denver_image)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
