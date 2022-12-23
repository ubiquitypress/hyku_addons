# frozen_string_literal: true

module Hyrax
  class EslnPresentationPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:esln_presentation)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
