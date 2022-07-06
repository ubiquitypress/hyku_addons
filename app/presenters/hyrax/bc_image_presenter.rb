# frozen_string_literal: true

module Hyrax
  class BcImagePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:bc_image)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
