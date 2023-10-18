# frozen_string_literal: true
module Hyrax
  class UnaImagePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:una_image)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
