# frozen_string_literal: true

class ConferenceItem < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:conference_item)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = ::ConferenceItemIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
