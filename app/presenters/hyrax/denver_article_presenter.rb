# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverArticle`
module Hyrax
  class DenverArticlePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:denver_article)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
