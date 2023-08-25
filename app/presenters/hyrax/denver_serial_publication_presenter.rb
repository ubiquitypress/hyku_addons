# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverSerialPublication`
module Hyrax
  class DenverSerialPublicationPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:denver_serial_publication)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
