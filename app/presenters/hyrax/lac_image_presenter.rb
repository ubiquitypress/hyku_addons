# frozen_string_literal: true

module Hyrax
  class LacImagePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:lac_image)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
