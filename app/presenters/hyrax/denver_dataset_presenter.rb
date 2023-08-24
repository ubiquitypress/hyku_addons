# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverDataset`
module Hyrax
  class DenverDatasetPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:denver_dataset)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
