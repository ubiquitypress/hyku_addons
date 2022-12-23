# frozen_string_literal: true

module Hyrax
  class EslnArchivalMaterialPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:esln_archival_material)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
