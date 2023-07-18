# frozen_string_literal: true

module Hyrax
  class ArchivalMaterialPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:archival_material)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
