# frozen_string_literal: true

module Hyrax
  class PacificThesisOrDissertationPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:pacific_thesis_or_dissertation)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
