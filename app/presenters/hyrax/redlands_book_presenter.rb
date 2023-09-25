# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsBook`
module Hyrax
  class RedlandsBookPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:redlands_book)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
