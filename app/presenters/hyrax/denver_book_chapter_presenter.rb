# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverBookChapter`
module Hyrax
  class DenverBookChapterPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:denver_book_chapter)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
