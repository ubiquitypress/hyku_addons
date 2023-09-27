# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsConferencesReportsAndPaper`
module Hyrax
  class RedlandsConferencesReportsAndPaperPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:redlands_conferences_reports_and_paper)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
