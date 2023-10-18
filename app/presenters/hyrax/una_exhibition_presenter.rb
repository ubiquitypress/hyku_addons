# frozen_string_literal: true

module Hyrax
  class UnaExhibitionPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:una_exhibition)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
