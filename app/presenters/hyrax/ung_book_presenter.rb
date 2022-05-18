# frozen_string_literal: true

module Hyrax
  class UngBookPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:ung_book)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
