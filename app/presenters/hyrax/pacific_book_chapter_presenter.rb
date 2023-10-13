# frozen_string_literal: true

module Hyrax
  class PacificBookChapterPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:pacific_book_chapter)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
