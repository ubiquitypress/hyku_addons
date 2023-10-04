# frozen_string_literal: true

module Hyrax
  class NsuGenericWorkPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:nsu_generic_work)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
