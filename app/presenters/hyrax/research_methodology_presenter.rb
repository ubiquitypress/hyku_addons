# frozen_string_literal: true

module Hyrax
  class ResearchMethodologyPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:research_methodology)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end