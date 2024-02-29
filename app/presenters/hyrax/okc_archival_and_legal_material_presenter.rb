# frozen_string_literal: true

module Hyrax
  class OkcArchivalAndLegalMaterialPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:okc_archival_and_legal_material)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
