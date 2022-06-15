# frozen_string_literal: true

module Hyrax
  class LtuImagePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:ltu_image)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
