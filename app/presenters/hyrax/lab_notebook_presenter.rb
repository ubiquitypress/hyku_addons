# frozen_string_literal: true

module Hyrax
  class LabNotebookPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:lab_notebook)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end