# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverBook`
class DenverBookIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:denver_book)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
