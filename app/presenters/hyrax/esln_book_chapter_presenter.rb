# frozen_string_literal: true

module Hyrax
  class EslnBookChapterPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:esln_book_chapter)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
