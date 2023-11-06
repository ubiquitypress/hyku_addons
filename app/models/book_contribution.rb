# frozen_string_literal: true

class BookContribution < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:book_contribution)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = ::BookContributionIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
