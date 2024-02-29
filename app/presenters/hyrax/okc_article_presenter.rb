# frozen_string_literal: true

module Hyrax
  class OkcArticlePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:okc_article)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
