# frozen_string_literal: true

module Hyrax
  class OkcImagePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:okc_image)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
