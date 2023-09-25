# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsBook`
class RedlandsBook < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:redlands_book)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = RedlandsBookIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
