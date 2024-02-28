# frozen_string_literal: true

module Hyrax
  class OkcPresentationPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:okc_presentation)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
