# frozen_string_literal: true

module Hyrax
  class LacThesisDissertationPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:lac_thesis_dissertation)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
