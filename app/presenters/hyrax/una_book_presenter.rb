# frozen_string_literal: true

module Hyrax
  class UnaBookPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:una_book)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
