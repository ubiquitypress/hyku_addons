# frozen_string_literal: true

module Hyrax
  class BcBookPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:bc_book)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
