# frozen_string_literal: true

module Hyrax
  class LacTimeBasedMediaPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:lac_time_based_media)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
