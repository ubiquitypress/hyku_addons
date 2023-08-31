# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverImage`
module Hyrax
  class DenverImagePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:denver_image)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
