# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsMedia`
module Hyrax
  class RedlandsMediaPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:redlands_media)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
