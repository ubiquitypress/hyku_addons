# frozen_string_literal: true

module Hyrax
  class BookContributionPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:book_contribution)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
