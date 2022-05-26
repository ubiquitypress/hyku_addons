# frozen_string_literal: true

module Hyrax
  class UngThesisDissertationPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:ung_thesis_dissertation)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
