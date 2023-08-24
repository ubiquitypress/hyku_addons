# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverPresentationMaterial`
class DenverPresentationMaterialIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:denver_presentation_material)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
