# frozen_string_literal: true

module Hyrax
  class TimeBasedMediaPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:time_based_media)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
