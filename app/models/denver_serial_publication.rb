# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverSerialPublication`
class DenverSerialPublication < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:denver_serial_publication)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = DenverSerialPublicationIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
