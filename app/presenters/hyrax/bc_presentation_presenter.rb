# frozen_string_literal: true

module Hyrax
  class BcPresentationPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:bc_presentation)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
