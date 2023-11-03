# frozen_string_literal: true

module Hyrax
  class ExhibitionItemPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:exhibition_item)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
