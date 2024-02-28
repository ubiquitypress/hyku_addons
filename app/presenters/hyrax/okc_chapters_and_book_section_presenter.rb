# frozen_string_literal: true

module Hyrax
  class OkcChaptersAndBookSectionPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:okc_chapters_and_book_section)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
