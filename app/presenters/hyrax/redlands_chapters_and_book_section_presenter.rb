# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsChaptersAndBookSection`
module Hyrax
  class RedlandsChaptersAndBookSectionPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:redlands_chapters_and_book_section)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
