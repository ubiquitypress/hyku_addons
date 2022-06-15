# frozen_string_literal: true

module Hyrax
  class LtuBookChapterPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:ltu_book_chapter)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
