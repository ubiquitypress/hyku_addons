# frozen_string_literal: true

module Hyrax
  class PacificArticlePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:pacific_article)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
