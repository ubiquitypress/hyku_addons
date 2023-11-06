# frozen_string_literal: true

module Hyrax
  class BookPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:book)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
