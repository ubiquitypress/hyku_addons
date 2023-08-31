# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverMap`
module Hyrax
  class DenverMapPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:denver_map)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
