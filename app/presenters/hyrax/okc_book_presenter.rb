# frozen_string_literal: true

module Hyrax
  class OkcBookPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:okc_book)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
