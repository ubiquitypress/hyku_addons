# frozen_string_literal: true

module Hyrax
  class ReportPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:report)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
