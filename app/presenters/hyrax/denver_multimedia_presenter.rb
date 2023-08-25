# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverMultimedia`
module Hyrax
  class DenverMultimediaPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:denver_multimedia)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
