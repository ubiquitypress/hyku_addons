# frozen_string_literal: true

module Hyrax
  class DatasetPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:dataset)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
