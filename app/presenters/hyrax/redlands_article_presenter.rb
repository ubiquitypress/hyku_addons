# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsArticle`
module Hyrax
  class RedlandsArticlePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:redlands_article)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
