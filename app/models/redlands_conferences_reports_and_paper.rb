# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsConferencesReportsAndPaper`
class RedlandsConferencesReportsAndPaper < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:redlands_conferences_reports_and_paper)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = RedlandsConferencesReportsAndPaperIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
