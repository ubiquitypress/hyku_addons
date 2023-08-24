# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverSerialPublication`
class DenverSerialPublicationIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:denver_serial_publication)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
