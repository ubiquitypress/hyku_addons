# frozen_string_literal: true

module Hyrax
  class GrantRecordPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:grant_record)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end