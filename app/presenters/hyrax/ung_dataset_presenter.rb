# frozen_string_literal: true

module Hyrax
  class UngDatasetPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:ung_dataset)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
