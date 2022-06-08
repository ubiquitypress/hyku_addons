# frozen_string_literal: true

module Hyrax
  class LtuArticlePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:ltu_article)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
