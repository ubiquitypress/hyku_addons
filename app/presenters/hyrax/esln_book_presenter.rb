# frozen_string_literal: true

module Hyrax
  class EslnBookPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:esln_book)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
