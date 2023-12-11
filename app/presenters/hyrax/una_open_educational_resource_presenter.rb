# frozen_string_literal: true
module Hyrax
  class UnaOpenEducationalResourcePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:una_open_educational_resource)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
