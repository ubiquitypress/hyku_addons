# frozen_string_literal: true

module Hyrax
  class OpenEducationalResourcePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:open_educational_resource)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end