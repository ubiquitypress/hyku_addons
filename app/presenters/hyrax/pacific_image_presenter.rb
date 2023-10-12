# frozen_string_literal: true

module Hyrax
  class PacificImagePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:pacific_image)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
