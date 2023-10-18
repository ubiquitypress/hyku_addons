# frozen_string_literal: true

module Hyrax
  class UnaArticlePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:una_article)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
