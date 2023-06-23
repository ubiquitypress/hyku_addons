# frozen_string_literal: true

module Hyrax
  class MinutePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:minute)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
