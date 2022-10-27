# frozen_string_literal: true

module Hyrax
  class LtuImageArtifactPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:ltu_image_artifact)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
