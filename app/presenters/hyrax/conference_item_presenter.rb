# frozen_string_literal: true

module Hyrax
  class ConferenceItemPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:conference_item)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
