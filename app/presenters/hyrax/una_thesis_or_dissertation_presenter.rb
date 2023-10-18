# frozen_string_literal: true
module Hyrax
  class UnaThesisOrDissertationPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:una_thesis_or_dissertation)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
