# frozen_string_literal: true

module Hyrax
  class UngImagePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:ung_image)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
