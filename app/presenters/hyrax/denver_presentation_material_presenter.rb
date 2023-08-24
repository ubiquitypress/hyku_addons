# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverPresentationMaterial`
module Hyrax
  class DenverPresentationMaterialPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:denver_presentation_material)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
