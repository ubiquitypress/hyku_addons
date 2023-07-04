# frozen_string_literal: true

module Hyrax
  class SoftwarePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:software)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end