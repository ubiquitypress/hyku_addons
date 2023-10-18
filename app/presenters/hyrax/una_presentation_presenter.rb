# frozen_string_literal: true

module Hyrax
  class UnaPresentationPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:una_presentation)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
