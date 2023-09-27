# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsConferencesReportsAndPaper`
module Hyrax
  # Generated form for RedlandsConferencesReportsAndPaper
  class RedlandsConferencesReportsAndPaperForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:redlands_conferences_reports_and_paper)

    self.model_class = ::RedlandsConferencesReportsAndPaper
  end
end
