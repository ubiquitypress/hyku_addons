# frozen_string_literal: true
module Hyrax
  class UnaChaptersAndBookSectionPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:una_chapters_and_book_section)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
