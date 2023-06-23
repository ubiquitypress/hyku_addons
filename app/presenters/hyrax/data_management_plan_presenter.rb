# frozen_string_literal: true

module Hyrax
  class DataManagementPlanPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:data_management_plan)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end