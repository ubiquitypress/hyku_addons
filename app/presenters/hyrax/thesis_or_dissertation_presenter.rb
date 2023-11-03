# frozen_string_literal: true

module Hyrax
  class ThesisOrDissertationPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:thesis_or_dissertation)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
