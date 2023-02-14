# frozen_string_literal: true

module Hyrax
  class PreprintPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:preprint)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
