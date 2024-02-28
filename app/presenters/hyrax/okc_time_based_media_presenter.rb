# frozen_string_literal: true

module Hyrax
  class OkcTimeBasedMediaPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:okc_time_based_media)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
