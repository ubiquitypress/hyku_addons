# frozen_string_literal: true

module Hyrax
  class NsuArticlePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:nsu_article)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
