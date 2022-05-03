# frozen_string_literal: true

module Hyrax
  class UnaArchivalItemPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:una_archival_item)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
