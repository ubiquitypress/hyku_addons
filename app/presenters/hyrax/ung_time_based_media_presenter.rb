# frozen_string_literal: true

module Hyrax
  class UngTimeBasedMediaPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:ung_time_based_media)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
