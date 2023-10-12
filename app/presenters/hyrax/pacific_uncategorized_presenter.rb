# frozen_string_literal: true

module Hyrax
  class PacificUncategorizedPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:pacific_uncategorized)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
