# frozen_string_literal: true

module Hyrax
  class LacArchivalMaterialPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:lac_archival_material)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
