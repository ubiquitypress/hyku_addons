# frozen_string_literal: true

module Hyrax
  class PacificNewsClippingPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:pacific_news_clipping)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
