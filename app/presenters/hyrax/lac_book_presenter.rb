# frozen_string_literal: true

module Hyrax
  class LacBookPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:lac_book)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
